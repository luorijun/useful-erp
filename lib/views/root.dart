import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:useful_erp/utils/events.dart';
import 'package:useful_erp/views/inbound/Inbound.dart';
import 'package:useful_erp/views/outbound/outbound.dart';
import 'package:useful_erp/views/production/production_view.dart';
import 'package:useful_erp/views/warehouse/warehouse.dart';

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  Widget _page = Container();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // 导航
              Navigation(onSelect: (page) {
                setState(() => _page = page);
              }),
              // 内容
              Expanded(
                child: Container(
                  child: _page,
                ),
              ),
            ],
          ),

          // 窗口控制栏
          const WindowTitleBar(),
        ],
      ),
    );
  }
}

// ==============================
// region 标题栏
// ==============================

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              child: Container(),
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (detail) {
                appWindow.startDragging();
              },
            ),
          ),
          FocusTraversalGroup(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                WindowButton(
                  icon: Icons.minimize,
                  onClick: () => appWindow.minimize(),
                ),
                WindowButton(
                  icon: Icons.square_outlined,
                  onClick: () => appWindow.maximizeOrRestore(),
                ),
                WindowButton.red(
                  icon: Icons.close,
                  onClick: () => appWindow.close(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class WindowButton extends StatelessWidget {
  WindowButton({
    Key? key,
    required this.icon,
    this.onClick,
  })  : color = null,
        super(key: key);

  WindowButton.red({
    Key? key,
    required this.icon,
    this.onClick,
  }) : super(key: key) {
    color = Colors.red;
  }

  final IconData icon;
  final Function? onClick;
  late Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hoverColor = color ?? theme.hoverColor;

    return InkWell(
      child: Container(
        child: Icon(icon, size: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      hoverColor: hoverColor,
      onTap: () => {
        if (onClick != null) {onClick!()}
      },
    );
  }
}

// endregion

// ==============================
// region 导航栏
// ==============================

class Navigation extends StatefulWidget {
  const Navigation({
    Key? key,
    required this.onSelect,
  }) : super(key: key);

  final ActionEvent<Widget> onSelect;

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  var _selected = 'home';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 256,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 导航菜单项
          FocusTraversalGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NavItem(
                  icon: Icons.shopping_cart,
                  label: "销售出库",
                  selected: _selected == 'consume',
                  onSelect: () {
                    widget.onSelect(Outbound());
                    setState(() {
                      _selected = 'consume';
                    });
                  },
                ),
                NavItem(
                  icon: Icons.move_to_inbox,
                  label: "登记入库",
                  selected: _selected == 'inbound',
                  onSelect: () {
                    widget.onSelect(InboundView());
                    setState(() {
                      _selected = 'inbound';
                    });
                  },
                ),
                NavItem(
                  icon: Icons.widgets,
                  label: "商品管理",
                  selected: _selected == 'production',
                  onSelect: () {
                    widget.onSelect(ProductionView());
                    setState(() {
                      _selected = 'production';
                    });
                  },
                ),
                NavItem(
                  icon: Icons.warehouse,
                  label: "仓库管理",
                  selected: _selected == 'warehouse',
                  onSelect: () {
                    widget.onSelect(WarehouseView());
                    setState(() {
                      _selected = 'warehouse';
                    });
                  },
                ),
              ],
            ),
          ),

          // 应用信息
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("version: 0.1.0"),
              ],
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            width: 1,
            color: theme.dividerColor,
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onSelect,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final bool selected;
  final Function onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8).copyWith(bottom: 0),
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Row(children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(label),
          ]),
        ),
        onTap: () => onSelect(),
      ),
    );
  }
}

// endregion
