import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: user == null
          ? const Center(
              child: Text('No hay usuario autenticado'),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Foto de perfil
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                          )
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // Nombre
                  Text(
                    user.displayName ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Correo
                  Text(
                    user.email ?? 'Sin correo',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // UID Firebase
                  SelectableText(
                    'UID:\n${user.uid}',
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Botón cerrar sesión
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
    );
  }
}
