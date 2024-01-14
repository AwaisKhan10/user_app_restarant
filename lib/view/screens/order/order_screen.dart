import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/web_header_skeleton.dart';
import 'package:efood_multivendor/view/screens/order/guest_track_order_input_view.dart';
import 'package:efood_multivendor/view/screens/order/widget/order_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    initCall();
  }

  void initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      Get.find<OrderController>().getRunningSubscriptionOrders(1, notify: false);
      Get.find<OrderController>().getHistoryOrders(1, notify: false);
      // Get.find<OrderController>().getSubscriptions(1, notify: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      appBar: CustomAppBar(title: 'my_orders'.tr, isBackButtonExist: ResponsiveHelper.isDesktop(context)),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: isLoggedIn ? GetBuilder<OrderController>(
        builder: (orderController) {
          return Column(children: [

            Container(
              color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
              child: Column(children: [

                ResponsiveHelper.isDesktop(context) ? Center(child: Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: Text('my_orders'.tr, style: robotoMedium),
                )) : const SizedBox(),

                Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Align(
                      alignment: ResponsiveHelper.isDesktop(context) ? Alignment.centerLeft : Alignment.center,
                      child: Container(
                        width: ResponsiveHelper.isDesktop(context) ? 350 : Dimensions.webMaxWidth,
                        color: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorWeight: 3,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Theme.of(context).disabledColor,
                          unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                          labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                          tabs: [
                            Tab(text: 'running'.tr),
                            Tab(text: 'subscription'.tr),
                            Tab(text: 'history'.tr),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              ),
            ),

            Expanded(child: TabBarView(
              controller: _tabController,
              children: const [
                OrderView(isRunning: true),
                OrderView(isRunning: false, isSubscription: true),
                OrderView(isRunning: false),
              ],
            )),

          ]);
        },
      ) : const GuestTrackOrderInputView(),
    );
  }
}
