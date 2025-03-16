// lib/views/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_driver_app/viewmodels/delivery_orders_viewmodel.dart';
import 'package:delivery_driver_app/viewmodels/profile_viewmodel.dart';
import 'package:delivery_driver_app/views/widgets/custom_app_bar.dart';
import 'package:delivery_driver_app/views/widgets/delivery_order_card.dart';
import 'package:delivery_driver_app/views/widgets/loading_indicator.dart';
import 'package:delivery_driver_app/models/delivery_order.dart';
import 'package:delivery_driver_app/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LocationService? _locationService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Start the location service when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      _locationService = LocationService(profileViewModel);
      _locationService?.startTracking();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _locationService?.dispose();
    super.dispose();
  }

  void _viewOrderDetails(DeliveryOrder order) {
    // Set the selected order in the ViewModel
    final ordersViewModel = Provider.of<DeliveryOrdersViewModel>(context, listen: false);
    ordersViewModel.selectOrder(order.id);
    
    // Navigate to the order details screen
    Navigator.of(context).pushNamed('/order-details');
  }

  Future<void> _refreshOrders() async {
    final ordersViewModel = Provider.of<DeliveryOrdersViewModel>(context, listen: false);
    await ordersViewModel.refreshOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/qr-scanner');
        },
        child: const Icon(Icons.qr_code_scanner),
        tooltip: 'Scan QR Code',
      ),
    );
  }

  CustomAppBar _buildAppBar() {
    return CustomAppBar(
      title: 'Deliveries',
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.of(context).pushNamed('/profile');
          },
          tooltip: 'Profile',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: _buildTabBarView(),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).primaryColor,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        tabs: const [
          Tab(text: 'Pending',),
          Tab(text: 'In Progress'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOrdersList(OrderStatus.pending),
        _buildOrdersList(OrderStatus.pickedUp),
        _buildOrdersList(OrderStatus.delivered),
      ],
    );
  }

  Widget _buildOrdersList(OrderStatus status) {
    return Consumer<DeliveryOrdersViewModel>(
      builder: (context, ordersViewModel, _) {
        if (ordersViewModel.isLoading) {
          return const LoadingIndicator();
        }

        List<DeliveryOrder> filteredOrders;
        switch (status) {
          case OrderStatus.pending:
            filteredOrders = ordersViewModel.pendingOrders;
            break;
          case OrderStatus.pickedUp:
            filteredOrders = ordersViewModel.inProgressOrders;
            break;
          case OrderStatus.delivered:
            filteredOrders = ordersViewModel.completedOrders;
            break;
        }

        if (filteredOrders.isEmpty) {
          return _buildEmptyState(status);
        }

        return RefreshIndicator(
          onRefresh: _refreshOrders,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 80),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return DeliveryOrderCard(
                order: order,
                onTap: () => _viewOrderDetails(order),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(OrderStatus status) {
    String message;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        message = 'No pending deliveries';
        icon = Icons.hourglass_empty;
        break;
      case OrderStatus.pickedUp:
        message = 'No deliveries in progress';
        icon = Icons.local_shipping;
        break;
      case OrderStatus.delivered:
        message = 'No completed deliveries';
        icon = Icons.check_circle;
        break;
    }

    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 80),
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}