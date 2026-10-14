import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/savings_product.dart';
import '../../providers/products/products_bloc.dart';
import '../../providers/view_status.dart';
import '../../widgets/animations.dart';
import '../../widgets/product_card.dart';
import '../../widgets/reconnect_listener.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/state_views.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ProductsBloc(getIt())..add(const ProductsRequested()),
    child: const _ProductsView(),
  );
}

class _ProductsView extends StatefulWidget {
  const _ProductsView();

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    final bloc = context.read<ProductsBloc>()..add(const ProductsRequested(forceRefresh: true));
    return bloc.stream.firstWhere((s) => !s.status.isLoading);
  }

  void _clearFilters() {
    _searchController.clear();
    context.read<ProductsBloc>()
      ..add(const ProductsSearchChanged(''))
      ..add(const ProductsFilterChanged(ProductTenor.all));
  }

  @override
  Widget build(BuildContext context) => ReconnectListener(
    onReconnect: _refresh,
    child: Scaffold(
      appBar: AppBar(title: const Text('Savings Products')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: _SearchAndFilters(controller: _searchController),
              ),
            ),
            _ProductsBody(onClearFilters: _clearFilters),
          ],
        ),
      ),
    ),
  );
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final filter = context.select((ProductsBloc bloc) => bloc.state.filter);
    final bloc = context.read<ProductsBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchBar(
          controller: controller,
          hintText: 'Search savings products',
          elevation: const WidgetStatePropertyAll(0),
          leading: const Icon(Icons.search_rounded),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: AppSpacing.lg)),
          trailing: [
            ListenableBuilder(
              listenable: controller,
              builder: (_, _) => controller.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        controller.clear();
                        bloc.add(const ProductsSearchChanged(''));
                      },
                    ),
            ),
          ],
          onChanged: (query) => bloc.add(ProductsSearchChanged(query)),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final tenor in ProductTenor.values)
              ChoiceChip(
                label: Text(tenor.label),
                selected: filter == tenor,
                onSelected: (_) => bloc.add(ProductsFilterChanged(tenor)),
              ),
          ],
        ),
      ],
    );
  }
}

class _ProductsBody extends StatelessWidget {
  const _ProductsBody({required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductsBloc>().state;

    return switch (state.status) {
      ViewStatus.initial || ViewStatus.loading => const _LoadingGrid(),
      ViewStatus.failure => SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(
          message: state.errorMessage ?? 'Could not load products.',
          onRetry: () => context.read<ProductsBloc>().add(const ProductsRequested()),
        ),
      ),
      ViewStatus.success when state.products.isEmpty => const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyView(
          icon: Icons.savings_outlined,
          title: 'No products available',
          message: 'New savings products will appear here soon.',
        ),
      ),
      ViewStatus.success when state.visibleProducts.isEmpty => SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyView(
          icon: Icons.search_off_rounded,
          title: 'No matching products',
          message: 'Try a different search term or filter.',
          action: TextButton(onPressed: onClearFilters, child: const Text('Clear filters')),
        ),
      ),
      ViewStatus.success => _ProductGrid(products: state.visibleProducts),
    };
  }
}

/// Lays cards out in 1–3 columns depending on the available width.
class _AdaptiveGrid extends StatelessWidget {
  const _AdaptiveGrid({required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
    sliver: SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns = width >= Breakpoints.expanded
            ? 3
            : width >= Breakpoints.medium
            ? 2
            : 1;
        if (columns == 1) {
          return SliverList.separated(
            itemCount: itemCount,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: itemBuilder,
          );
        }
        final itemWidth = (width - AppSpacing.md * (columns - 1)) / columns;
        return SliverToBoxAdapter(
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (var i = 0; i < itemCount; i++)
                SizedBox(width: itemWidth, child: itemBuilder(context, i)),
            ],
          ),
        );
      },
    ),
  );
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});

  final List<SavingsProduct> products;

  @override
  Widget build(BuildContext context) => _AdaptiveGrid(
    itemCount: products.length,
    itemBuilder: (context, index) {
      final product = products[index];
      return FadeSlideIn(
        key: ValueKey(product.id),
        index: index,
        child: ProductCard(
          product: product,
          onViewDetails: () => context.go(AppRoutes.productDetails(product.id), extra: product),
        ),
      );
    },
  );
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) => _AdaptiveGrid(
    itemCount: 4,
    itemBuilder: (_, _) =>
        const SkeletonPulse(child: SkeletonBox(height: 210, radius: AppRadius.lg)),
  );
}
