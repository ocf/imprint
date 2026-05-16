<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */

/** TODO should be handled properly, possibly by k8s secrets? */
define( 'DB_NAME', 'meow' );

/** Database username */
define( 'DB_USER', 'meowuser' );

/** Database password */
define( 'DB_PASSWORD', 'meowpassword' );

/** Database hostname */
define( 'DB_HOST', 'mariadb' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         '%[-r;yx~VQMmH9sw=5O4)aYolAe:-,;80{u_@r`VG>S!z`;+v@wL?/-utAD@c~Mh' );
define( 'SECURE_AUTH_KEY',  'SH$~~}~EKx)blD~Z@U*B0eyt+E~&$Z{|So$bTNTUr.iZx<<,P@IZA[|cPBX; Qy5' );
define( 'LOGGED_IN_KEY',    'S Ny_w{@9=CNhcV7-N^D/>v|5/K=j;x6,xRY<#H(FObZ3Mf#+x$cKDC!qcKsbW##' );
define( 'NONCE_KEY',        '[mT>6OGTdoBts;KHt|u3-WoY+|*#6)>bFrm3>rcjKPdUkuKBvhqAN)Dt,/g5zzw$' );
define( 'AUTH_SALT',        'q]wA/2##a*!VG<0u{L7kuc+u(-p?$y4V$^STyU7]/VYvr{Bl5j+Q?T%QM;!Hsk9:' );
define( 'SECURE_AUTH_SALT', '5z%`.QIDMQOD~T(IffS}sXi>h&%nLt)RD_o#WOM#._K&[$G58TjWY[x,1_vaD38I' );
define( 'LOGGED_IN_SALT',   'Cs2VkXBuj7GpGAe$3TeVZ,Sgm[XrQQ&CeC/EtWw[Na[Sb3@`oipcz.#CH4cFhKw2' );
define( 'NONCE_SALT',       'tI_/:{3S|K#$`nr:BZ!F@$vy%?6N-]-?C6!-%:*EorBQTFNnw+-ML+W0%I^>oHm2' );

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', '/tmp/wp-errors.log' );

/* Add any custom values between this line and the "stop editing" line. */

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname(__FILE__) . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

