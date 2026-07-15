<?php
/** TODO should be handled properly, possibly by k8s secrets? */
define( 'DB_NAME', getenv('DB_NAME') );
define( 'DB_USER', getenv('DB_USER') );
define( 'DB_PASSWORD', getenv('DB_PASSWORD') );
define( 'DB_HOST', getenv('DB_HOST') );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );

define( 'AUTH_KEY',         '%[-r;yx~VQMmH9sw=5O4)aYolAe:-,;80{u_@r`VG>S!z`;+v@wL?/-utAD@c~Mh' );
define( 'SECURE_AUTH_KEY',  'SH$~~}~EKx)blD~Z@U*B0eyt+E~&$Z{|So$bTNTUr.iZx<<,P@IZA[|cPBX; Qy5' );
define( 'LOGGED_IN_KEY',    'S Ny_w{@9=CNhcV7-N^D/>v|5/K=j;x6,xRY<#H(FObZ3Mf#+x$cKDC!qcKsbW##' );
define( 'NONCE_KEY',        '[mT>6OGTdoBts;KHt|u3-WoY+|*#6)>bFrm3>rcjKPdUkuKBvhqAN)Dt,/g5zzw$' );
define( 'AUTH_SALT',        'q]wA/2##a*!VG<0u{L7kuc+u(-p?$y4V$^STyU7]/VYvr{Bl5j+Q?T%QM;!Hsk9:' );
define( 'SECURE_AUTH_SALT', '5z%`.QIDMQOD~T(IffS}sXi>h&%nLt)RD_o#WOM#._K&[$G58TjWY[x,1_vaD38I' );
define( 'LOGGED_IN_SALT',   'Cs2VkXBuj7GpGAe$3TeVZ,Sgm[XrQQ&CeC/EtWw[Na[Sb3@`oipcz.#CH4cFhKw2' );
define( 'NONCE_SALT',       'tI_/:{3S|K#$`nr:BZ!F@$vy%?6N-]-?C6!-%:*EorBQTFNnw+-ML+W0%I^>oHm2' );

$table_prefix = 'wp_';

# Override WordPress URL by environment variable
define( 'WP_SITEURL', getenv('PRIMARY_URL') );
define( 'WP_HOME', getenv('PRIMARY_URL') );

# Errors should be logged, but not shown to the user
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', '/var/log/wp-errors.log' );
define( 'WP_DEBUG_DISPLAY', false );

# Must be set, otherwise Wordpress tries to find it in the nix store
define( 'WP_CONTENT_DIR', '/share/wordpress/wp-content' );

# The install/themes/plugins are constant and cannot be updated by the user
define( 'AUTOMATIC_UPDATER_DISABLED', true );
define( 'WP_AUTO_UPDATE_CORE', false );
define( 'DISALLOW_FILE_MODS', true );

# Requests to wordpress.org will fail and cause slowdowns otherwise
#define( 'WP_HTTP_BLOCK_EXTERNAL', true );

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname(__FILE__) . '/' );
}

require_once ABSPATH . 'wp-settings.php';

