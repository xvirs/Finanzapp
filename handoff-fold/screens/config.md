# Configuración · adaptativo

## Compact (<600 dp)

Sin cambios. Lista vertical de secciones, cada una con su pantalla aparte (push).

## Expanded (600–1023 dp · Fold inner)

Master/detail.

```
┌──────┬─────────────────┬─────────────────┐
│ RAIL │ MASTER          │ DETAIL          │
│  88  │                 │                 │
│      │ Sesión card     │ (de la sección  │
│      │                 │  seleccionada)  │
│ Mes  │ DATOS           │                 │
│ Tar  │ • Cuentas (9)   │ Header + filtros│
│ Cfg* │ • Tarjetas (3)  │ + grid 2 col    │
│      │                 │                 │
│      │ PREFERENCIAS    │ + acciones      │
│      │ • Seguridad     │                 │
│      │ • Notif         │                 │
│      │ • Apariencia    │                 │
│      │ • Cuenta        │                 │
│      │                 │                 │
│      │ Cerrar sesión   │                 │
└──────┴─────────────────┴─────────────────┘
```

Default selection: "Cuentas fijas".

## Desktop (≥1024 dp)

Sidebar dual (244) + main grid 3 col + aside 320 (ya implementado en web).

## Sub-pantallas del detail

### Cuentas fijas

- Header: H2 "Cuentas fijas" + buscador + "Nueva cuenta"
- Stats: Total · Estimado mes · Variables · Próx vto
- Tabs categoría: Todas · Servicios · Subs · Impuestos · Salud · **Ingresos**
- Grid 2-3 col de `AccountCard`:
  - Top: ícono categoría | chip tipo (FIJA/VARIABLE)
  - Body: nombre + sub mono
  - Bottom: label + monto

### Tarjetas

Reusa la grid de la pantalla Tarjetas pero sin el aside (acá el aside es el editor).

### Seguridad

- Toggle bloqueo biométrico
- PIN backup
- Sesiones activas (lista)

### Notificaciones

- Toggle por categoría
- Días de antelación

### Apariencia

- Tema (System/Dark/Light)
- Densidad (Cómodo/Compacto)
- Idioma

### Cuenta

- Email
- Plan
- Exportar datos
- Borrar cuenta

## Aside · editor de cuenta seleccionada

Form vertical:
- Identidad: ícono categoría + nombre
- TextFields: Nombre, Categoría, Día, Tipo (Fija/Variable), Estimado promedio
- Toggles: Recordatorio (días antes) · Cuenta activa
- Histórico 6 meses (bar chart inline)
- Acciones: `Guardar cambios` (primary) + `Eliminar cuenta` (outline rojo)
