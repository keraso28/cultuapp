import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart'; // Importante para la tipografía
import 'package:url_launcher/url_launcher.dart';
import 'package:table_calendar/table_calendar.dart';

// --- COLORES PRINCIPALES DEL DISEÑO ---
const Color colorPrimario = Color(0xFF4C28E8); // El púrpura/azul de tus botones y fondos
const Color colorFondo = Color(0xFFF8F9FA); // Fondo gris muy claro
const Color colorTextoSecundario = Color(0xFF6B7280);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ¡PON TUS CREDENCIALES REALES DE SUPABASE AQUÍ!
  await Supabase.initialize(
    url: 'https://kiaxvwclnvrdjupsqpbt.supabase.co',
    anonKey: 'sb_publishable_YBfE-fyWymmk6MbpHoS6Gw_kZB7Gt8b',
  );
  runApp(const CultuApp());
}

class CultuApp extends StatelessWidget {
  const CultuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CultuApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: colorFondo,
        primaryColor: colorPrimario,
        // Usamos Google Fonts para darle el estilo de tu Figma
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: colorPrimario),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: const SplashPage(), 
    );
  }
}

// --- PANTALLA SPLASH (Estilo Figma) ---
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirigirUsuario();
  }

  Future<void> _redirigirUsuario() async {
    await Future.delayed(const Duration(seconds: 2)); 
    final sesion = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;
    if (sesion != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigator()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimario,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Círculo con estrella (Placeholder del logo)
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu guía de cultura en\nPasto',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white, 
                fontSize: 28, 
                fontWeight: FontWeight.bold,
                height: 1.2
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA DE LOGIN (Estilo Figma) ---
// --- PANTALLA DE LOGIN (F3) ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _ingresar() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    try {
      // Ahora el login SOLO inicia sesión, ya no crea cuentas automáticamente
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigator()));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales incorrectas o usuario no encontrado'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inicia sesión', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Accede con tu correo o teléfono para recibir alertas personalizadas.', style: TextStyle(color: colorTextoSecundario, fontSize: 16)),
            const SizedBox(height: 32),
            
            const Text('Correo o teléfono', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'ejemplo@correo.com',
                filled: true, fillColor: colorFondo,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••••••',
                filled: true, fillColor: colorFondo,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            
            const SizedBox(height: 32),
            _isLoading 
              ? const Center(child: CircularProgressIndicator(color: colorPrimario))
              : Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _ingresar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimario, padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text('Ingresar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navegamos a la nueva pantalla de registro
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroScreen()));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87, side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text('Crear cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA DE REGISTRO (F14) ---
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _crearCuenta() async {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, completa todos los campos')));
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Guardamos al usuario inyectando su nombre en la metadata de Supabase
      await Supabase.instance.client.auth.signUp(
        email: email, 
        password: password,
        data: {'nombre_completo': nombre},
      );
      if (mounted) {
        // Si tiene éxito, cerramos todas las vistas y entramos a la app
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigator()), (route) => false);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear cuenta: $e'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crear cuenta', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Regístrate para guardar favoritos y recibir notificaciones personalizadas.', style: TextStyle(color: colorTextoSecundario, fontSize: 16)),
            const SizedBox(height: 32),
            
            const Text('Nombre completo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(hintText: 'Ej: Juan Pérez', filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
            ),
            const SizedBox(height: 16),
            
            const Text('Correo o teléfono', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'ejemplo@correo.com', filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
            ),
            const SizedBox(height: 16),

            const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController, obscureText: true,
              decoration: InputDecoration(hintText: '••••••••', filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
            ),
            const SizedBox(height: 16),

            const Text('Confirmar contraseña', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController, obscureText: true,
              decoration: InputDecoration(hintText: '••••••••', filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
            ),
            
            const SizedBox(height: 32),
            _isLoading 
              ? const Center(child: CircularProgressIndicator(color: colorPrimario))
              : Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _crearCuenta,
                        style: ElevatedButton.styleFrom(backgroundColor: colorPrimario, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                        child: const Text('Crear cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Ya tengo cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

// --- NAVEGADOR PRINCIPAL (5 PESTAÑAS - CON CALENDARIO) ---
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _pantallas = [
    const HomeFigmaScreen(), // 0. Inicio
    const ExplorarScreen(),  // 1. Explorar
    const CalendarioScreen(),// 2. Calendario (¡NUEVO!)
    const FavoritosScreen(), // 3. Alertas / Favoritos
    const PerfilScreen(),    // 4. Perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6200EA), 
        unselectedItemColor: Colors.grey[400],
        backgroundColor: Colors.white,
        elevation: 15,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explorar'),
          // Cambiamos el ícono del mapa por el del calendario
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Alertas'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// --- PANTALLA INICIO (ACTUALIZADA CON CARRUSEL, LIMPIEZA Y BOTÓN FLOTANTE) ---
class HomeFigmaScreen extends StatefulWidget {
  const HomeFigmaScreen({super.key});

  @override
  State<HomeFigmaScreen> createState() => _HomeFigmaScreenState();
}

class _HomeFigmaScreenState extends State<HomeFigmaScreen> {
  List<dynamic> _eventos = [];
  bool _isLoading = true;
  String _categoriaSeleccionada = 'Todos';
  
  // Controlador para el efecto carrusel (el 0.92 deja ver un pedacito de la siguiente tarjeta)
  final PageController _pageController = PageController(viewportFraction: 0.92);

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    try {
      final supabase = Supabase.instance.client;
      
      // 1. EL BARRENDERO: Buscar eventos que ya pasaron y aún tienen imagen
      final ahora = DateTime.now().toIso8601String();
      final expirados = await supabase.from('eventos').select().lt('fecha', ahora).not('imagen_url', 'is', null);

      for (var evento in expirados) {
        final String imageUrl = evento['imagen_url'];
        if (imageUrl.isNotEmpty) {
          final nombreArchivo = imageUrl.split('/').last; // Sacamos el nombre de la foto
          try {
            // Borramos el archivo pesado del Storage para liberar espacio
            await supabase.storage.from('eventos').remove([nombreArchivo]);
            // Actualizamos la base de datos dejando el evento pero sin foto
            await supabase.from('eventos').update({'imagen_url': null}).eq('id', evento['id']);
          } catch (e) {
            debugPrint('Error limpiando foto vieja: $e');
          }
        }
      }

      // 2. Cargar la lista fresca y actualizada para mostrarla
      final response = await supabase.from('eventos').select().order('fecha', ascending: true);
          
      if (mounted) {
        setState(() {
          _eventos = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtro de categorías
    final eventosFiltrados = _categoriaSeleccionada == 'Todos'
        ? _eventos
        : _eventos.where((e) => e['categoria'] == _categoriaSeleccionada).toList();

    // Tomamos hasta 3 eventos para el carrusel destacado
    final eventosDestacados = _eventos.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      // ¡AQUÍ ESTÁ EL BOTÓN FLOTANTE PARA AÑADIR NUEVOS EVENTOS!
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6200EA),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          // Vamos a crear uno nuevo, y al regresar refrescamos la lista
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearEventoScreen()))
            .then((_) => _cargarEventos());
        },
      ),
      
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6200EA)))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // 1. EL CARRUSEL DINÁMICO
                  SizedBox(
                    height: 220,
                    child: eventosDestacados.isEmpty
                        ? const Center(child: Text('No hay eventos próximos'))
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: eventosDestacados.length,
                            itemBuilder: (context, index) {
                              return _construirTarjetaDestacada(eventosDestacados[index]);
                            },
                          ),
                  ),
                  
                  const SizedBox(height: 24),

                  // 2. FILTROS DE CATEGORÍA
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      // Categoría "Arte" lista
                      children: ['Todos', 'Música', 'Teatro', 'Arte', 'Cine'].map((categoria) {
                        final isSelected = _categoriaSeleccionada == categoria;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(categoria, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            selected: isSelected,
                            selectedColor: const Color(0xFF6200EA),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: isSelected ? const Color(0xFF6200EA) : Colors.grey[300]!),
                            onSelected: (selected) {
                              if (selected) setState(() => _categoriaSeleccionada = categoria);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // 3. SECCIÓN "ESTA SEMANA" (Limpia, sin el "Ver todos")
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Esta semana', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  
                  const SizedBox(height: 16),

                  // 4. LISTA VERTICAL DE EVENTOS DE LA CATEGORÍA
                  Expanded(
                    child: eventosFiltrados.isEmpty
                        ? const Center(child: Text('No hay eventos en esta categoría'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: eventosFiltrados.length,
                            itemBuilder: (context, index) {
                              return _construirTarjetaLista(eventosFiltrados[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  // WIDGET: La tarjeta grande deslizable del carrusel
  Widget _construirTarjetaDestacada(Map<String, dynamic> evento) {
    String textoFecha = 'Próximamente';
    if (evento['fecha'] != null) {
      final f = DateTime.parse(evento['fecha']).toLocal();
      final ampm = f.hour >= 12 ? 'PM' : 'AM';
      final h = f.hour > 12 ? f.hour - 12 : (f.hour == 0 ? 12 : f.hour);
      final m = f.minute.toString().padLeft(2, '0');
      textoFecha = '${f.day}/${f.month} • $h:$m $ampm';
    }

    return GestureDetector(
      onTap: () {
        // Al tocar y regresar, actualizamos la lista por si lo borraste o editaste
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetalleEventoScreen(evento: evento)))
          .then((_) => _cargarEventos());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF6200EA), 
          borderRadius: BorderRadius.circular(24),
          image: evento['imagen_url'] != null && evento['imagen_url'].toString().isNotEmpty
            ? DecorationImage(
                image: NetworkImage(evento['imagen_url']),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
              ) 
            : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'DESTACADO • ${(evento['categoria'] ?? 'CULTURA').toString().toUpperCase()}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  evento['titulo'] ?? 'Sin título',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  evento['lugar'] ?? 'Pasto',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                  const SizedBox(width: 8),
                  Text(textoFecha, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: La tarjeta pequeña de la lista de abajo
  Widget _construirTarjetaLista(Map<String, dynamic> evento) {
    return GestureDetector(
      onTap: () {
        // Al tocar y regresar, actualizamos la lista por si lo borraste o editaste
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetalleEventoScreen(evento: evento)))
          .then((_) => _cargarEventos());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: evento['imagen_url'] != null && evento['imagen_url'].toString().isNotEmpty
                  ? Image.network(evento['imagen_url'], width: 100, height: 100, fit: BoxFit.cover)
                  : Container(width: 100, height: 100, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(evento['titulo'] ?? 'Evento', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(evento['lugar'] ?? 'Pasto', style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(
                      evento['precio'] == 0 || evento['precio'] == null ? 'Gratis' : '\$${evento['precio']}',
                      style: const TextStyle(color: Color(0xFF6200EA), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA PERFIL DINÁMICO (F11) ACTUALIZADx|A ---
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _email = '';
  String _nombre = '';
  String _telefono = '';
  String _direccion = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email ?? 'Sin correo';
        final meta = user.userMetadata;
        _nombre = meta?['nombre_completo'] ?? 'Usuario Cultural';
        
        // Si no existen, mostramos el texto por defecto
        final tel = meta?['telefono']?.toString().trim() ?? '';
        final dir = meta?['direccion']?.toString().trim() ?? '';
        
        _telefono = tel.isNotEmpty ? tel : 'No especificado';
        _direccion = dir.isNotEmpty ? dir : 'No especificado';
      });
    }
  }

  Future<void> _cerrarSesion() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
  }

  Widget _buildItemPerfil(IconData icono, String titulo, String subtitulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: colorFondo, shape: BoxShape.circle),
            child: Icon(icono, color: colorPrimario, size: 20),
          ),
          title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          subtitle: Text(subtitulo, style: TextStyle(color: subtitulo == 'No especificado' ? Colors.grey : Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      // Usamos un AppBar del mismo color para poner el botón de editar sin dañar tu diseño
      appBar: AppBar(
        backgroundColor: colorPrimario,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              // Navegamos a editar y cuando regrese, recargamos los datos
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditarPerfilScreen()));
              _cargarDatos();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 40), // Reduje el padding superior porque ya tenemos AppBar
              decoration: const BoxDecoration(color: colorPrimario, borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45, backgroundColor: Colors.white,
                    child: Text(
                      _nombre.isNotEmpty ? _nombre[0].toUpperCase() : 'U',
                      style: const TextStyle(color: colorPrimario, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nombre, 
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(_email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('DATOS PERSONALES', style: TextStyle(color: colorTextoSecundario, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 8),
            
            _buildItemPerfil(Icons.person_outline, 'Nombre', _nombre),
            _buildItemPerfil(Icons.email_outlined, 'Correo', _email),
            _buildItemPerfil(Icons.phone_outlined, 'Teléfono', _telefono),
            _buildItemPerfil(Icons.location_on_outlined, 'Dirección', _direccion),
            
            const SizedBox(height: 32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _cerrarSesion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red, side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA PARA EDITAR PERFIL ---
class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cargamos los datos actuales en las cajas de texto
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata;
      _nombreController.text = meta?['nombre_completo'] ?? '';
      _telefonoController.text = meta?['telefono'] ?? '';
      _direccionController.text = meta?['direccion'] ?? '';
    }
  }

  Future<void> _guardarCambios() async {
    setState(() => _isLoading = true);
    try {
      // Actualizamos la metadata en Supabase
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'nombre_completo': _nombreController.text.trim(),
            'telefono': _telefonoController.text.trim(),
            'direccion': _direccionController.text.trim(),
          },
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado con éxito'), backgroundColor: Colors.green));
        Navigator.pop(context); // Regresamos a la pantalla anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre completo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 20),

            const Text('Teléfono', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(hintText: 'Ej: 300 123 4567', filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 20),

            const Text('Dirección', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _direccionController,
              decoration: InputDecoration(hintText: 'Ej: Calle 10 # 5-20, Pasto', filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 40),

            _isLoading
                ? const Center(child: CircularProgressIndicator(color: colorPrimario))
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _guardarCambios,
                      style: ElevatedButton.styleFrom(backgroundColor: colorPrimario, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                      child: const Text('Guardar cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA DETALLE DE EVENTO (F5) ---
class DetalleEventoScreen extends StatefulWidget {
  final Map<String, dynamic> evento;
  const DetalleEventoScreen({super.key, required this.evento});

  @override
  State<DetalleEventoScreen> createState() => _DetalleEventoScreenState();
}

class _DetalleEventoScreenState extends State<DetalleEventoScreen> {
  bool _esFavorito = false;

  @override
  void initState() {
    super.initState();
    _verificarFavorito();
  }

  Future<void> _verificarFavorito() async {
    final usuario = Supabase.instance.client.auth.currentUser;
    if (usuario == null) return;
    
    try {
      final response = await Supabase.instance.client
          .from('favoritos')
          .select()
          .eq('usuario_id', usuario.id)
          .eq('evento_id', widget.evento['id']);
          
      if (mounted && response.isNotEmpty) {
        setState(() => _esFavorito = true);
      }
    } catch (e) {
      debugPrint('Error al verificar favorito: $e');
    }
  }

  Future<void> _toggleFavorito() async {
    final usuario = Supabase.instance.client.auth.currentUser;
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicia sesión para guardar favoritos')));
      return;
    }

    try {
      if (_esFavorito) {
        await Supabase.instance.client
            .from('favoritos')
            .delete()
            .eq('usuario_id', usuario.id)
            .eq('evento_id', widget.evento['id']);
      } else {
        await Supabase.instance.client.from('favoritos').insert({
          'usuario_id': usuario.id,
          'evento_id': widget.evento['id'],
        });
      }
      if (mounted) setState(() => _esFavorito = !_esFavorito);
    } catch (e) {
      debugPrint('Error al cambiar favorito: $e');
    }
  }

  Future<void> _activarAlertaInterna() async {
    final usuario = Supabase.instance.client.auth.currentUser;
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicia sesión para activar alertas')));
      return;
    }

    if (!_esFavorito) {
      await _toggleFavorito(); 
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Agendado! Revisa tu Calendario y tus Alertas.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final evento = widget.evento;
    final String? imagenUrl = evento['imagen_url'];
    
    // Formateo de fecha para que se vea elegante
    String textoFecha = 'Fecha por definir';
    if (evento['fecha'] != null) {
      final f = DateTime.parse(evento['fecha']).toLocal();
      final ampm = f.hour >= 12 ? 'PM' : 'AM';
      final h = f.hour > 12 ? f.hour - 12 : (f.hour == 0 ? 12 : f.hour);
      final m = f.minute.toString().padLeft(2, '0');
      textoFecha = '${f.day}/${f.month}/${f.year} - $h:$m $ampm';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // BOTÓN EDITAR (Requiere que CrearEventoScreen esté actualizado)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CrearEventoScreen(eventoAEditar: widget.evento)));
            },
          ),
          // BOTÓN ELIMINAR
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar Evento'),
                  content: const Text('¿Estás seguro de que deseas borrar este evento de forma permanente?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirmar == true) {
                try {
                  // 1. Borramos la foto de la nube (si tiene)
                  if (widget.evento['imagen_url'] != null) {
                    final nombreArchivo = widget.evento['imagen_url'].toString().split('/').last;
                    await Supabase.instance.client.storage.from('eventos').remove([nombreArchivo]);
                  }
                  // 2. Borramos el evento de la base de datos
                  await Supabase.instance.client.from('eventos').delete().eq('id', widget.evento['id']);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento eliminado con éxito'), backgroundColor: Colors.green));
                    Navigator.pop(context); // Regresa a la pantalla anterior
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red));
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Imagen del evento
            if (imagenUrl != null && imagenUrl.isNotEmpty)
              Image.network(imagenUrl, width: double.infinity, height: 250, fit: BoxFit.cover)
            else
              Container(width: double.infinity, height: 250, color: Colors.grey[200], child: const Icon(Icons.image, size: 64, color: Colors.grey)),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Título y Botón Favorito
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(evento['titulo'] ?? 'Sin título', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                      IconButton(
                        icon: Icon(_esFavorito ? Icons.favorite : Icons.favorite_border, color: _esFavorito ? Colors.red : Colors.grey, size: 32),
                        onPressed: _toggleFavorito,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 3. Detalles: Lugar, Fecha, Precio, Categoría
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF6200EA), size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(evento['lugar'] ?? 'Lugar por definir', style: const TextStyle(fontSize: 16, color: Colors.black87))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF6200EA), size: 20),
                      const SizedBox(width: 8),
                      Text(textoFecha, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Color(0xFF6200EA), size: 20),
                      const SizedBox(width: 8),
                      Text(evento['precio'] == 0 || evento['precio'] == null ? 'Entrada Libre' : '\$${evento['precio']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF6200EA).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(evento['categoria'] ?? 'General', style: const TextStyle(color: Color(0xFF6200EA), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 4. Descripción
                  const Text('Acerca del evento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    (evento['descripcion'] != null && evento['descripcion'].toString().isNotEmpty) 
                        ? evento['descripcion'] 
                        : 'No hay descripción disponible para este evento.',
                    style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 80), // Espacio para que el botón de abajo no tape el texto
                ],
              ),
            ),
          ],
        ),
      ),
      
      // 5. Botón Fijo Inferior
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: _activarAlertaInterna,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6200EA), 
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Activar Alerta', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}

// --- PANTALLA DE MIS ALERTAS (FAVORITOS) ---
class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<dynamic> _eventosFavoritos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    final usuario = Supabase.instance.client.auth.currentUser;
    if (usuario == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Obtenemos los IDs guardados por el usuario actual
      final favs = await Supabase.instance.client.from('favoritos').select('evento_id').eq('user_id', usuario.id);
      final List<int> favIds = favs.map<int>((f) => f['evento_id'] as int).toList();

      if (favIds.isEmpty) {
        setState(() {
          _eventosFavoritos = [];
          _isLoading = false;
        });
        return;
      }

      // 2. Traemos los eventos y filtramos los que coinciden con nuestros favoritos
      final todosLosEventos = await Supabase.instance.client.from('eventos').select().order('created_at', ascending: false);
      final filtrados = todosLosEventos.where((e) => favIds.contains(e['id'])).toList();

      setState(() {
        _eventosFavoritos = filtrados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Mis Alertas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: colorPrimario))
          : _eventosFavoritos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Aún no tienes alertas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      const Text('Toca el corazón en un evento para guardarlo.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _eventosFavoritos.length,
                  itemBuilder: (context, index) {
                    final evento = _eventosFavoritos[index];
                    final String? imagenUrl = evento['imagen_url'];
                    
                    return GestureDetector(
                      onTap: () {
                        // Navega al detalle y al volver recarga la lista por si el usuario quitó el favorito
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetalleEventoScreen(evento: evento)),
                        ).then((_) => _cargarFavoritos());
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                              child: imagenUrl != null && imagenUrl.isNotEmpty
                                  ? Image.network(imagenUrl, width: 100, height: 120, fit: BoxFit.cover)
                                  : Container(width: 100, height: 120, color: colorPrimario.withOpacity(0.1), child: const Icon(Icons.image, color: Colors.grey)),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text((evento['categoria'] ?? 'Cultura').toUpperCase(), style: const TextStyle(color: colorPrimario, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(evento['titulo'] ?? 'Sin título', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 8),
                                    Text(evento['lugar'] ?? 'Lugar por definir', style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ),
                            // Botón rápido para eliminar de favoritos directamente desde la lista
                            IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () async {
                                final usuario = Supabase.instance.client.auth.currentUser;
                                if(usuario != null) {
                                  await Supabase.instance.client.from('favoritos').delete().match({'user_id': usuario.id, 'evento_id': evento['id']});
                                  _cargarFavoritos(); // Actualiza la lista para que desaparezca al instante
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// --- PANTALLA EXPLORAR (BÚSQUEDA Y CATEGORÍAS) ---
class ExplorarScreen extends StatefulWidget {
  const ExplorarScreen({super.key});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  List<dynamic> _todosLosEventos = [];
  List<dynamic> _eventosFiltrados = [];
  bool _isLoading = true;
  
  String _textoBusqueda = '';
  String _categoriaSeleccionada = 'Todos';

  final List<String> _categorias = ['Todos', 'Música', 'Teatro', 'Feria', 'Cine', 'Arte', 'Danza'];

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    try {
      // Descargamos los eventos ordenados por fecha
      final response = await Supabase.instance.client
          .from('eventos')
          .select()
          .order('fecha', ascending: true);
          
      if (mounted) {
        setState(() {
          // Asignamos los datos a las variables correctas de esta pantalla
          _todosLosEventos = response;
          _eventosFiltrados = response; 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _eventosFiltrados = _todosLosEventos.where((evento) {
        final titulo = (evento['titulo'] ?? '').toString().toLowerCase();
        final categoria = (evento['categoria'] ?? 'Cultura').toString();

        final coincideBusqueda = titulo.contains(_textoBusqueda.toLowerCase());
        final coincideCategoria = _categoriaSeleccionada == 'Todos' || categoria == _categoriaSeleccionada;

        return coincideBusqueda && coincideCategoria;
      }).toList();
    });
  }

  Widget _buildCategoryChip(String text) {
    final bool isSelected = _categoriaSeleccionada == text;
    return GestureDetector(
      onTap: () {
        _categoriaSeleccionada = text;
        _aplicarFiltros();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6200EA) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF6200EA) : Colors.grey[300]!),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // colorFondo
      appBar: AppBar(
        title: const Text('Explorar Eventos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (value) {
                _textoBusqueda = value;
                _aplicarFiltros();
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          // Categorías
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categorias.map((cat) => _buildCategoryChip(cat)).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 8),

          // Cuadrícula de eventos (Grid)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6200EA)))
                : _eventosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No se encontraron eventos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Dos columnas
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75, // Proporción de las tarjetas
                        ),
                        itemCount: _eventosFiltrados.length,
                        itemBuilder: (context, index) {
                          final evento = _eventosFiltrados[index];
                          final String? imagenUrl = evento['imagen_url'];
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DetalleEventoScreen(evento: evento)),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: imagenUrl != null && imagenUrl.isNotEmpty
                                          ? Image.network(imagenUrl, width: double.infinity, fit: BoxFit.cover)
                                          : Container(color: const Color(0xFF6200EA).withOpacity(0.1), child: const Center(child: Icon(Icons.image, color: Colors.grey))),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text((evento['categoria'] ?? 'Cultura').toUpperCase(), style: const TextStyle(color: Color(0xFF6200EA), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                          Text(evento['titulo'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          Text(evento['precio'] == 0 ? 'Gratis' : '\$${evento['precio']}', style: const TextStyle(color: Color(0xFF6200EA), fontWeight: FontWeight.bold, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// --- PANTALLA CREAR EVENTO (MODO ADMIN) ---
// --- PANTALLA CREAR / EDITAR EVENTO ---
class CrearEventoScreen extends StatefulWidget {
  final Map<String, dynamic>? eventoAEditar; // Si llega lleno, es modo Edición
  const CrearEventoScreen({super.key, this.eventoAEditar});

  @override
  State<CrearEventoScreen> createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  final _tituloController = TextEditingController();
  final _lugarController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController(text: '0');
  
  String _categoria = 'Música';
  DateTime? _fechaSeleccionada;
  File? _imagenSeleccionada;
  String? _imagenUrlExistente;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Si estamos editando, llenamos los campos con los datos del evento
    if (widget.eventoAEditar != null) {
      final e = widget.eventoAEditar!;
      _tituloController.text = e['titulo'] ?? '';
      _lugarController.text = e['lugar'] ?? '';
      _descripcionController.text = e['descripcion'] ?? '';
      _precioController.text = (e['precio'] ?? 0).toString();
      _categoria = e['categoria'] ?? 'Música';
      if (e['fecha'] != null) _fechaSeleccionada = DateTime.parse(e['fecha']).toLocal();
      _imagenUrlExistente = e['imagen_url'];
    }
  }

  // ... (Conserva tu función _seleccionarImagen y _seleccionarFechaHora exactamente iguales aquí) ...
  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) setState(() => _imagenSeleccionada = File(imagen.path));
  }

  Future<void> _seleccionarFechaHora() async {
    final DateTime? fecha = await showDatePicker(context: context, initialDate: _fechaSeleccionada ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (fecha != null && mounted) {
      final TimeOfDay? hora = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (hora != null) setState(() => _fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute));
    }
  }

  Future<void> _guardarEvento() async {
    if (_tituloController.text.trim().isEmpty || _lugarController.text.trim().isEmpty || _fechaSeleccionada == null || (_imagenSeleccionada == null && _imagenUrlExistente == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan campos obligatorios'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String urlFinal = _imagenUrlExistente ?? ''; // Usamos la que ya tenía por defecto

      // Si el usuario eligió una foto nueva, la subimos
      if (_imagenSeleccionada != null) {
        final extension = _imagenSeleccionada!.path.split('.').last;
        final nombreArchivo = '${DateTime.now().millisecondsSinceEpoch}.$extension';
        await Supabase.instance.client.storage.from('eventos').upload(nombreArchivo, _imagenSeleccionada!);
        urlFinal = Supabase.instance.client.storage.from('eventos').getPublicUrl(nombreArchivo);
      }

      final datosEvento = {
        'titulo': _tituloController.text.trim(),
        'lugar': _lugarController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'precio': int.tryParse(_precioController.text.trim()) ?? 0,
        'imagen_url': urlFinal.isEmpty ? null : urlFinal,
        'categoria': _categoria,
        'fecha': _fechaSeleccionada!.toIso8601String(),
      };

      if (widget.eventoAEditar == null) {
        // CREAR NUEVO
        await Supabase.instance.client.from('eventos').insert(datosEvento);
      } else {
        // ACTUALIZAR EXISTENTE
        await Supabase.instance.client.from('eventos').update(datosEvento).eq('id', widget.eventoAEditar!['id']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado con éxito'), backgroundColor: Colors.green));
        Navigator.pop(context); // Vuelve atrás
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    String textoFecha = 'Seleccionar Fecha y Hora *';
    if (_fechaSeleccionada != null) {
      textoFecha = '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year} - ${_fechaSeleccionada!.hour}:${_fechaSeleccionada!.minute.toString().padLeft(2,'0')}';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.eventoAEditar == null ? 'Crear Nuevo Evento' : 'Editar Evento', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÁREA DE SUBIDA DE IMAGEN
            GestureDetector(
              onTap: _seleccionarImagen,
              child: Container(
                width: double.infinity, height: 200,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[300]!)),
                child: _imagenSeleccionada != null 
                  ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_imagenSeleccionada!, fit: BoxFit.cover))
                  : (_imagenUrlExistente != null && _imagenUrlExistente!.isNotEmpty
                      ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(_imagenUrlExistente!, fit: BoxFit.cover))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey[400]),
                            Text('Toca para subir una foto *', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                          ],
                        )),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Título *', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _tituloController),
            const SizedBox(height: 16),
            
            const Text('Categoría *', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _categoria,
              items: ['Música', 'Teatro', 'Arte', 'Cine', 'Feria'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _categoria = val!),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(onPressed: _seleccionarFechaHora, icon: const Icon(Icons.calendar_today, color: Color(0xFF6200EA)), label: Text(textoFecha)),
            const SizedBox(height: 16),

            const Text('Lugar *', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _lugarController),
            const SizedBox(height: 16),

            const Text('Precio (\$) *', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _precioController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),

            const Text('Descripción (Opcional)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            TextField(controller: _descripcionController, maxLines: 4),
            const SizedBox(height: 32),

            _isLoading ? const Center(child: CircularProgressIndicator()) : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarEvento,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6200EA), padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA DE CALENDARIO (NUEVA PESTAÑA 3) ---
class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _diaSeleccionado = DateTime.now();
  DateTime _mesEnfocado = DateTime.now();
  
  List<dynamic> _todosLosEventos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    try {
      final response = await Supabase.instance.client.from('eventos').select();
      if (mounted) {
        setState(() {
          _todosLosEventos = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Filtra los eventos para que solo se muestren los del día que tocaste
  List<dynamic> _obtenerEventosDelDia(DateTime dia) {
    return _todosLosEventos.where((evento) {
      if (evento['fecha'] == null) return false;
      final fechaEvento = DateTime.parse(evento['fecha']).toLocal();
      return isSameDay(fechaEvento, dia);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventosHoy = _obtenerEventosDelDia(_diaSeleccionado);

    return Scaffold(
      backgroundColor: Colors.grey[50], // colorFondo
      appBar: AppBar(
        title: const Text('Calendario Cultural', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6200EA)))
          : Column(
              children: [
                // 1. El Calendario Visual
                Container(
                  color: Colors.white,
                  child: TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _mesEnfocado,
                    selectedDayPredicate: (day) => isSameDay(_diaSeleccionado, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _diaSeleccionado = selectedDay;
                        _mesEnfocado = focusedDay;
                      });
                    },
                    // Ponemos un puntito morado en los días que tienen eventos
                    eventLoader: _obtenerEventosDelDia,
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(color: Colors.black12, shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: Color(0xFF6200EA), shape: BoxShape.circle),
                      markerDecoration: BoxDecoration(color: Color(0xFF6200EA), shape: BoxShape.circle),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 2. Lista de eventos del día seleccionado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      eventosHoy.isEmpty ? 'No hay eventos para esta fecha' : 'Eventos programados:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),

                Expanded(
                  child: eventosHoy.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('Día libre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: eventosHoy.length,
                          itemBuilder: (context, index) {
                            final evento = eventosHoy[index];
                            final String? imagenUrl = evento['imagen_url'];
                            
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DetalleEventoScreen(evento: evento)));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(8),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imagenUrl != null && imagenUrl.isNotEmpty
                                        ? Image.network(imagenUrl, width: 60, height: 60, fit: BoxFit.cover)
                                        : Container(width: 60, height: 60, color: const Color(0xFF6200EA).withOpacity(0.1), child: const Icon(Icons.image, color: Colors.grey)),
                                  ),
                                  title: Text(evento['titulo'] ?? 'Sin título', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(evento['lugar'] ?? 'Lugar por definir', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}