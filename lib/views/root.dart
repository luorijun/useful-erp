import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_erp/router.dart';

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // 页面
        Row(children: const [
          Navigation(),
          Expanded(child: RouterNode('root')),
        ]),

        // 标题栏
        const WindowTitleBar(),
      ]),
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

class Navigation extends StatelessWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 256,
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 导航菜单项
          FocusTraversalGroup(
            child: Builder(builder: (context) {
              final router = context.watch<RouterState>().child;
              final navigator = router?.key.currentState!;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NavItem(
                    icon: Icons.shopping_cart,
                    label: "销售出库",
                    selected: router == null ? false : router.current?.name == 'outbound-edit-batch',
                    onSelect: () {
                      if (navigator == null || router?.current?.name == 'outbound-edit-batch') return;
                      navigator.pushNamed('outbound-edit-batch');
                    },
                  ),
                  NavItem(
                    icon: Icons.outbox,
                    label: "出库记录",
                    selected: router == null ? false : router.current?.name == 'outbound',
                    onSelect: () {
                      if (navigator == null || router?.current?.name == 'outbound') return;
                      navigator.pushNamed('outbound');
                    },
                  ),
                  // NavItem(
                  //   icon: Icons.edit_note,
                  //   label: "登记入库",
                  //   selected: router == null ? false : router.current?.name == 'inbound-edit-batch',
                  //   onSelect: () {
                  //     if (navigator == null || router?.current?.name == 'inbound-edit-batch') return;
                  //     navigator.pushNamed('inbound-edit-batch');
                  //   },
                  // ),
                  NavItem(
                    icon: Icons.move_to_inbox,
                    label: "入库记录",
                    selected: router == null ? false : router.current?.name == 'inbound',
                    onSelect: () {
                      if (navigator == null || router?.current?.name == 'inbound') return;
                      navigator.pushNamed('inbound');
                    },
                  ),
                  NavItem(
                    icon: Icons.widgets,
                    label: "商品管理",
                    selected: router == null ? false : router.current?.name == 'production',
                    onSelect: () {
                      if (navigator == null || router?.current?.name == 'production') return;
                      navigator.pushNamed('production');
                    },
                  ),
                  NavItem(
                    icon: Icons.warehouse,
                    label: "仓库管理",
                    selected: router == null ? false : router.current?.name == 'warehouse',
                    onSelect: () {
                      if (navigator == null || router?.current?.name == 'warehouse') return;
                      navigator.pushNamed('warehouse');
                    },
                  ),
                ],
              );
            }),
          ),

          // 应用信息
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("v0.2.0"),
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
    final theme = Theme.of(context);

    return Container(
      width: double.maxFinite,
      height: 48,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: TextButton.icon(
        icon: Icon(
          icon,
          color: selected ? Colors.white : Colors.black87,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
        onPressed: () => onSelect(),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: selected ? theme.primaryColor : Colors.transparent,
        ),
      ),
    );
  }
}

// endregion
