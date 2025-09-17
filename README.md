# ESX Legacy Housing System

Sistema de casas para ESX Legacy que utiliza ox_lib para menús y notificaciones.

## Características

- **Compra y venta de casas**: Los jugadores pueden comprar casas disponibles y vender las que poseen
- **Interfaz con ox_lib**: Menús interactivos y notificaciones modernas
- **Persistencia en base de datos**: Todas las propiedades se guardan en MySQL
- **Sistema de blips**: Marcadores en el mapa que cambian de color según disponibilidad
- **Comandos útiles**: Acceso rápido a listas de casas
- **Valor de reventa**: Los jugadores reciben el 80% del valor al vender

## Instalación

1. Asegúrate de tener instalados los siguientes recursos:
   - `es_extended` (ESX Legacy)
   - `ox_lib`
   - `oxmysql`

2. Coloca este recurso en tu carpeta de recursos de FiveM

3. Añade `ensure housing-system` a tu server.cfg

4. La base de datos se creará automáticamente al iniciar el recurso

## Configuración

Edita `config.lua` para:
- Modificar casas existentes o añadir nuevas
- Cambiar el porcentaje de reventa
- Personalizar mensajes y configuraciones de blips

## Comandos

- `/casas` - Muestra la lista de todas las casas disponibles
- `/miscasas` - Muestra las casas que posee el jugador

## Uso

1. **Ver casas disponibles**: Usa el comando `/casas` o acércate a cualquier marcador de casa en el mapa
2. **Comprar una casa**: Acércate a la casa y presiona `E`, luego selecciona "Comprar Casa"
3. **Vender una casa**: Acércate a una casa que poseas y presiona `E`, luego selecciona "Vender Casa"
4. **Navegación**: Desde los menús de listas, puedes marcar rutas GPS hacia las casas

## Estructura de archivos

- `fxmanifest.lua` - Manifiesto del recurso
- `config.lua` - Configuración de casas y mensajes
- `server.lua` - Lógica del servidor y base de datos
- `client.lua` - Lógica del cliente e interfaz
- `README.md` - Documentación

## Base de datos

El sistema crea automáticamente la tabla `houses` con la siguiente estructura:

```sql
CREATE TABLE houses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    house_id INT NOT NULL UNIQUE,
    owner VARCHAR(60) DEFAULT NULL,
    owned BOOLEAN DEFAULT FALSE,
    INDEX(house_id),
    INDEX(owner)
)
```

## Dependencias

- ESX Legacy
- ox_lib
- oxmysql