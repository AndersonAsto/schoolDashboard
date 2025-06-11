import 'package:flutter/material.dart';
import 'package:schooldashboard/Screens/TeacherScreens/assistancesScreen.dart';
import 'package:schooldashboard/Screens/TeacherScreens/incidentsScreen.dart';
import 'package:schooldashboard/Screens/TeacherScreens/qualificationsScreen.dart';
import 'package:sidebarx/sidebarx.dart';

const sidebarCanvasColor = Color(0xff3b7861); // Color de fondo del sidebar
const sidebarAccentCanvasColor = Color(0xff256d7b); // Un color más claro para el gradiente del item seleccionado
const sidebarActionColor = Color(0xff204760); // Color para el borde del item seleccionado (sin opacidad aquí)
final sidebarDivider = Divider(color: Colors.white.withOpacity(0.3), height: 1); // Divisor sutil para sidebar

class TeacherNavigationRail extends StatefulWidget {
  final int docenteId;
  final String userName;

  const TeacherNavigationRail({
    super.key,
    required this.docenteId,
    required this.userName
  });

  @override
  State<TeacherNavigationRail> createState() => _TeacherNavigationRailState();
}

class _TeacherNavigationRailState extends State<TeacherNavigationRail> {
  final SidebarXController _controller = SidebarXController(selectedIndex: 0, extended: true);

  @override
  Widget build(BuildContext context) {
    final pages = [
      AssistancesScreenClass(docenteId: widget.docenteId, userName: widget.userName),
      QualificationsScreenClass(docenteId: widget.docenteId, userName: widget.userName),
      IncidentsScreenClass(docenteId: widget.docenteId, userName: widget.userName),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCollapsed = constraints.maxWidth < 700;
        _controller.setExtended(!isCollapsed);
        return Scaffold(
          // El Scaffold heredará el tema global de main.dart, incluyendo el fondo blanco.
          body: Row(
            children: [
              SidebarX(
                controller: _controller,
                theme: SidebarXTheme(
                  margin: const EdgeInsets.all(10), // Margen alrededor del sidebar
                  decoration: BoxDecoration(
                    color: sidebarCanvasColor, // Fondo del sidebar (tu verde oscuro)
                    borderRadius: BorderRadius.circular(20), // Bordes redondeados
                  ),
                  // === ESTADO HOVER ===
                  hoverColor: Colors.white.withOpacity(0.1), // Un hover sutil
                  hoverTextStyle: const TextStyle(
                    color: Colors.white, // Texto blanco al hacer hover
                    fontWeight: FontWeight.w500,
                  ),
                  hoverIconTheme: const IconThemeData(
                    color: Colors.white, // Icono blanco al hacer hover
                    size: 20, // Mantener tamaño consistente
                  ),
                  // === ESTADO NO SELECCIONADO ===
                  textStyle: TextStyle(color: Colors.white.withOpacity(0.7)), // Texto translúcido para no seleccionado
                  iconTheme: IconThemeData(
                    color: Colors.white.withOpacity(0.7), // Icono translúcido para no seleccionado
                    size: 20,
                  ),
                  // === ESTADO SELECCIONADO ===
                  selectedTextStyle: const TextStyle(color: Colors.white), // Texto blanco para seleccionado
                  selectedIconTheme: const IconThemeData(
                    color: Colors.white, // Icono blanco para seleccionado
                    size: 20,
                  ),
                  selectedItemDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sidebarActionColor.withOpacity(0.37), // Borde con `sidebarActionColor`
                    ),
                    gradient: const LinearGradient( // Gradiente para el fondo del item seleccionado
                      colors: [sidebarAccentCanvasColor, sidebarCanvasColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.28),
                        blurRadius: 30,
                      )
                    ],
                  ),
                  // === ESPACIADO ===
                  itemTextPadding: const EdgeInsets.only(left: 16), // Espacio para no seleccionado
                  selectedItemTextPadding: const EdgeInsets.only(left: 16), // Espacio para seleccionado (consistente)
                  itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Ajusta según necesites más o menos "aire"
                  itemDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sidebarCanvasColor), // Borde igual al fondo del sidebar
                  ),
                  padding: const EdgeInsets.all(0),
                ),
                extendedTheme: const SidebarXTheme(
                  width: 200, // Ancho del sidebar extendido
                  decoration: BoxDecoration(
                    color: sidebarCanvasColor, // Mismo color de fondo
                  ),
                ),
                footerDivider: sidebarDivider, // El divisor definido en las constantes
                headerBuilder: (context, extended) {
                  return SizedBox(
                    height: 120, // Altura del header
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: extended
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Para evitar overflow, podemos usar Flexible o Expanded en el texto
                        // si hay otros elementos en la columna.
                        // Si es solo el texto, el overflow: ellipsis debería bastar,
                        // pero la altura de la SizedBox debe ser suficiente.
                        children: [
                          const Flexible(child: Text(
                            'Bienvenid@,',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),),
                          const SizedBox(height: 5),
                          // Aquí, envolvemos el Text con Flexible para que se adapte
                          // al espacio disponible dentro del Column.
                          Flexible( // <-- CAMBIO AQUÍ
                            child: Text(
                              widget.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis, // Ya lo tenías, pero es crucial
                              maxLines: 1, // Limita a una línea para evitar que ocupe más espacio vertical
                            ),
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Colors.white.withOpacity(0.5), height: 3),
                        ],
                      )
                          : const Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                  );
                },
                items: const [
                  SidebarXItem(
                    icon: Icons.assignment_outlined,
                    label: 'Asistencias',
                  ),
                  SidebarXItem(
                    icon: Icons.check_box_outlined,
                    label: 'Calificaciones',
                  ),
                  SidebarXItem(
                    icon: Icons.dangerous_outlined,
                    label: 'Incidencias',
                  ),
                ],
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return pages[_controller.selectedIndex];
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}