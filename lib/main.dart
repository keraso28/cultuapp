import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart'; // Importante para la tipografía

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
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigator()));
    } catch (e1) {
      try {
        await Supabase.instance.client.auth.signUp(email: email, password: password);
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigator()));
      } catch (e2) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al iniciar sesión')));
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
            Text('Accede con tu correo o teléfono para recibir alertas personalizadas.', style: TextStyle(color: colorTextoSecundario, fontSize: 16)),
            const SizedBox(height: 32),
            
            Text('Correo o teléfono', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'ejemplo@correo.com',
                filled: true,
                fillColor: colorFondo,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            
            Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••••••',
                filled: true,
                fillColor: colorFondo,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            
            const SizedBox(height: 32),
            _isLoading 
              ? const Center(child: CircularProgressIndicator(color: colorPrimario))
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _ingresar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimario,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Ingresar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// --- NAVEGADOR PRINCIPAL (Barra inferior) ---
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  
  // Lista de las pantallas a las que navegamos
  final List<Widget> _pantallas = [
    const HomeFigmaScreen(), 
    const Center(child: Text('Pantalla Explorar (Próximamente)')),
    const Center(child: Text('Pantalla Mapa (Próximamente)')),
    const Center(child: Text('Pantalla Alertas (Próximamente)')),
    const PerfilScreen(), // ¡AQUÍ AGREGAMOS LA NUEVA PANTALLA!
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorPrimario,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), activeIcon: Icon(Icons.location_on), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), activeIcon: Icon(Icons.notifications), label: 'Alertas'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// --- PANTALLA INICIO CLON FIGMA (Conectada a Supabase) ---
class HomeFigmaScreen extends StatefulWidget {
  const HomeFigmaScreen({super.key});

  @override
  State<HomeFigmaScreen> createState() => _HomeFigmaScreenState();
}

class _HomeFigmaScreenState extends State<HomeFigmaScreen> {
  List<dynamic> _eventos = [];
  List<int> _favoritosIds = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  
  // --- NUEVAS VARIABLES PARA LOS FILTROS ---
  String _categoriaSeleccionada = 'Todos';
  String _textoBusqueda = '';

  @override
  void initState() {
    super.initState();
    _verificarRol();
    _obtenerDatos();
  }

  void _verificarRol() {
    final usuario = Supabase.instance.client.auth.currentUser;
    if (usuario != null && usuario.email == 'admin@cultuapp.com') {
      setState(() {
        _isAdmin = true;
      });
    }
  }

  Future<void> _obtenerDatos() async {
    try {
      final responseEventos = await Supabase.instance.client.from('eventos').select().order('created_at', ascending: false);
      
      final usuario = Supabase.instance.client.auth.currentUser;
      List<int> favs = [];
      if (usuario != null) {
        final responseFavs = await Supabase.instance.client
            .from('favoritos')
            .select('evento_id')
            .eq('user_id', usuario.id);
        favs = responseFavs.map<int>((f) => f['evento_id'] as int).toList();
      }

      setState(() {
        _eventos = responseEventos;
        _favoritosIds = favs;
        _isLoading = false;
      });
    } catch (e) {
      print('ERROR AL CARGAR DATOS: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorito(int eventoId) async {
    final usuario = Supabase.instance.client.auth.currentUser;
    if (usuario == null) return;
    final esFavorito = _favoritosIds.contains(eventoId);

    setState(() {
      if (esFavorito) _favoritosIds.remove(eventoId);
      else _favoritosIds.add(eventoId);
    });

    try {
      if (esFavorito) {
        await Supabase.instance.client.from('favoritos').delete().match({'user_id': usuario.id, 'evento_id': eventoId});
      } else {
        await Supabase.instance.client.from('favoritos').insert({'user_id': usuario.id, 'evento_id': eventoId});
      }
    } catch (e) {
      setState(() {
        if (esFavorito) _favoritosIds.add(eventoId);
        else _favoritosIds.remove(eventoId);
      });
    }
  }

  // --- WIDGET DE CATEGORÍA ACTUALIZADO ---
  // Ahora es táctil y cambia la variable de estado
  Widget _buildCategoryChip(String text) {
    final bool isSelected = _categoriaSeleccionada == text;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _categoriaSeleccionada = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorPrimario : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? colorPrimario : Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : colorTextoSecundario,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE FILTRADO ---
    // Filtramos la lista original antes de dibujarla en pantalla
    final eventosFiltrados = _eventos.where((evento) {
      final titulo = (evento['titulo'] ?? '').toString().toLowerCase();
      final categoria = (evento['categoria'] ?? 'Cultura').toString();

      // Verifica si el título contiene lo que escribimos en el buscador
      final coincideBusqueda = titulo.contains(_textoBusqueda.toLowerCase());
      
      // Verifica si la categoría coincide (si es 'Todos', siempre pasa)
      final coincideCategoria = _categoriaSeleccionada == 'Todos' || categoria == _categoriaSeleccionada;

      return coincideBusqueda && coincideCategoria;
    }).toList();

    return Scaffold(
      backgroundColor: colorFondo,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CABECERA PÚRPURA ---
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorPrimario,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: colorPrimario.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✦ ALERTA CULTURAL • PASTO, NARIÑO', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Descubre la cultura\nviva de Pasto', style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.1)),
                    const SizedBox(height: 12),
                    const Text('Conciertos, ferias, teatro y carnaval en un solo lugar.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, foregroundColor: colorPrimario, elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Explorar', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Mis alertas'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.circle, color: Colors.white70, size: 8),
                          SizedBox(width: 8),
                          Text('Próx. Noche de Máscaras • Vie 9 • 7 PM', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // --- BARRA DE BÚSQUEDA ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  // Escucha cada tecla que presionas y actualiza la búsqueda
                  onChanged: (value) {
                    setState(() {
                      _textoBusqueda = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar eventos en Pasto...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey[200]!)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- CATEGORÍAS ---
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip('Todos'),
                    _buildCategoryChip('Música'),
                    _buildCategoryChip('Teatro'),
                    _buildCategoryChip('Feria'),
                    _buildCategoryChip('Cine'), // Puedes agregar más
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- TÍTULO DE SECCIÓN ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Esta semana', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Ver todos', style: TextStyle(color: colorPrimario, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- CARRUSEL HORIZONTAL DE EVENTOS (Ahora usa eventosFiltrados) ---
              _isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: colorPrimario)))
                  : eventosFiltrados.isEmpty // Verificamos la lista filtrada
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text('No encontramos eventos', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 16),
                            itemCount: eventosFiltrados.length, // Usamos la lista filtrada
                            itemBuilder: (context, index) {
                              final evento = eventosFiltrados[index]; // Usamos la lista filtrada
                              final bool esFavorito = _favoritosIds.contains(evento['id']);
                              final String? imagenUrl = evento['imagen_url'];
                              
                              String fechaMostrada = '';
                              if (evento['fecha'] != null) {
                                final DateTime fecha = DateTime.parse(evento['fecha']).toLocal();
                                final List<String> dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                                final diaStr = dias[fecha.weekday - 1];
                                final ampm = fecha.hour >= 12 ? 'PM' : 'AM';
                                var hora12 = fecha.hour > 12 ? fecha.hour - 12 : (fecha.hour == 0 ? 12 : fecha.hour);
                                final minutos = fecha.minute.toString().padLeft(2, '0');
                                fechaMostrada = '${evento['lugar']} • $diaStr ${fecha.day} • $hora12:$minutos $ampm';
                              }

                              return Container(
                                width: 220,
                                margin: const EdgeInsets.only(right: 16, bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                          child: imagenUrl != null && imagenUrl.isNotEmpty
                                              ? Image.network(imagenUrl, height: 130, width: double.infinity, fit: BoxFit.cover)
                                              : Container(
                                                  height: 130, 
                                                  color: colorPrimario.withOpacity(0.1),
                                                  child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                                                ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 18,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(esFavorito ? Icons.favorite : Icons.favorite_border, color: esFavorito ? Colors.red : Colors.grey[400], size: 20),
                                              onPressed: () => _toggleFavorito(evento['id']),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (evento['categoria'] ?? 'Cultura').toUpperCase(),
                                            style: const TextStyle(color: colorPrimario, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            evento['titulo'] ?? 'Sin título',
                                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            fechaMostrada,
                                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            evento['precio'] == 0 ? 'Gratis' : '\$${evento['precio']}',
                                            style: const TextStyle(color: colorPrimario, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              backgroundColor: colorPrimario,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearEventoScreen()))
                    .then((_) => _obtenerDatos()); 
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

// --- PANTALLA PARA CREAR EVENTOS ---
class CrearEventoScreen extends StatefulWidget {
  const CrearEventoScreen({super.key});
  @override
  State<CrearEventoScreen> createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _lugarController = TextEditingController();
  final _precioController = TextEditingController();
  final _categoriaController = TextEditingController();
  
  bool _isSaving = false;
  File? _imagenSeleccionada; 
  DateTime? _fechaSeleccionada;

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) setState(() => _imagenSeleccionada = File(imagen.path));
  }

  Future<void> _seleccionarFechaHora() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: colorPrimario)), child: child!),
    );
    if (fecha != null && mounted) {
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: colorPrimario)), child: child!),
      );
      if (hora != null) {
        setState(() => _fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute));
      }
    }
  }

  Future<void> _guardarEvento() async {
    if (_tituloController.text.isEmpty || _fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El título y la fecha son obligatorios')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      String? imageUrl;
      if (_imagenSeleccionada != null) {
        final fileExt = _imagenSeleccionada!.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        await Supabase.instance.client.storage.from('eventos_imagenes').upload(fileName, _imagenSeleccionada!);
        imageUrl = Supabase.instance.client.storage.from('eventos_imagenes').getPublicUrl(fileName);
      }
      await Supabase.instance.client.from('eventos').insert({
        'titulo': _tituloController.text, 'descripcion': _descripcionController.text,
        'lugar': _lugarController.text, 'precio': int.tryParse(_precioController.text) ?? 0,
        'categoria': _categoriaController.text.isEmpty ? 'Cultura' : _categoriaController.text,
        'fecha': _fechaSeleccionada!.toIso8601String(), 'imagen_url': imageUrl, 
      });
      if (mounted) Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Nuevo Evento', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _seleccionarImagen,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: colorFondo, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: _imagenSeleccionada != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(_imagenSeleccionada!, fit: BoxFit.cover))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Toca para añadir afiche', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(controller: _tituloController, decoration: InputDecoration(labelText: 'Título del evento', filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            TextField(controller: _descripcionController, decoration: InputDecoration(labelText: 'Descripción', filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), maxLines: 3),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              tileColor: colorFondo,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(_fechaSeleccionada == null ? 'Seleccionar Fecha y Hora' : 'Fecha: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year} • ${_fechaSeleccionada!.hour}:${_fechaSeleccionada!.minute.toString().padLeft(2, '0')}', style: TextStyle(color: _fechaSeleccionada == null ? Colors.grey[700] : Colors.black, fontSize: 16)),
              leading: const Icon(Icons.calendar_month, color: colorPrimario),
              onTap: _seleccionarFechaHora,
            ),
            const SizedBox(height: 12),
            TextField(controller: _lugarController, decoration: InputDecoration(labelText: 'Lugar (Ej: Teatro Imperial)', filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            TextField(controller: _precioController, decoration: InputDecoration(labelText: 'Precio (0 si es gratis)', filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _categoriaController, decoration: InputDecoration(labelText: 'Categoría (Ej: Música, Teatro)', filled: true, fillColor: colorFondo, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 32),
            _isSaving
                ? const Center(child: CircularProgressIndicator(color: colorPrimario))
                : ElevatedButton(
                    onPressed: _guardarEvento,
                    style: ElevatedButton.styleFrom(backgroundColor: colorPrimario, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    child: const Text('Publicar Evento', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA PERFIL (Clon F11) ---
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _email = '';

  @override
  void initState() {
    super.initState();
    // Obtenemos el usuario actual de Supabase al cargar la pantalla
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _email = user.email ?? 'Sin correo';
    }
  }

  Future<void> _cerrarSesion() async {
    // Cerramos sesión en la nube
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      // Navegamos al Login y borramos el historial para que no pueda volver atrás con la flecha
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // Pequeño widget para no repetir el código de las tarjetas de datos
  Widget _buildItemPerfil(IconData icono, String titulo, String subtitulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: colorFondo, shape: BoxShape.circle),
            child: Icon(icono, color: colorPrimario, size: 20),
          ),
          title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          subtitle: Text(subtitulo, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CABECERA PÚRPURA ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, bottom: 40),
              decoration: const BoxDecoration(
                color: colorPrimario,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Text(
                      _email.isNotEmpty ? _email[0].toUpperCase() : 'U',
                      style: const TextStyle(color: colorPrimario, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kevin Eraso', // Por ahora lo dejamos fijo como en tu diseño
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email, // Este es dinámico, viene de Supabase
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('DATOS PERSONALES', style: TextStyle(color: colorTextoSecundario, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 8),
            
            // --- TARJETAS DE DATOS ---
            _buildItemPerfil(Icons.person_outline, 'Nombre', 'Kevin Eraso'),
            _buildItemPerfil(Icons.email_outlined, 'Correo', _email),
            _buildItemPerfil(Icons.phone_outlined, 'Teléfono', '+57 3XX XXX XXXX'),
            _buildItemPerfil(Icons.location_on_outlined, 'Dirección', 'Pasto, Nariño, Colombia'),
            
            const SizedBox(height: 32),
            
            // --- BOTONES DE ACCIÓN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _cerrarSesion, // ¡Llama a nuestra función de logout!
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        backgroundColor: Colors.red.withOpacity(0.05),
                        side: BorderSide(color: Colors.red.withOpacity(0.3), width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Ayuda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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