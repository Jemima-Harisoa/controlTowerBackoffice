package util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DatabaseConnection {
    private static DatabaseConnection instance;
    private Properties properties;
    
    private DatabaseConnection() {
        try {
            properties = new Properties();
            InputStream inputStream = getClass().getClassLoader().getResourceAsStream("application.properties");
            if (inputStream != null) {
                properties.load(inputStream);
            } else {
                throw new RuntimeException("Fichier application.properties non trouvé");
            }
        } catch (IOException e) {
            throw new RuntimeException("Erreur lors du chargement du fichier application.properties", e);
        }
    }
    
    public static synchronized DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }
    
    /**
     * Récupère une propriété en priorité depuis les variables d'environnement,
     * sinon depuis application.properties
     */
    private String getProperty(String envName, String propName) {
        String envValue = System.getenv(envName);
        if (envValue != null && !envValue.isEmpty()) {
            return envValue;
        }
        return properties.getProperty(propName);
    }

    /**
     * Récupère la première variable d'environnement non vide parmi plusieurs clés,
     * sinon retourne la propriété du fichier application.properties.
     */
    private String getPropertyFromEnvAliases(String[] envNames, String propName) {
        if (envNames != null) {
            for (String envName : envNames) {
                if (envName == null || envName.isEmpty()) {
                    continue;
                }
                String envValue = System.getenv(envName);
                if (envValue != null && !envValue.isEmpty()) {
                    return envValue;
                }
            }
        }
        return properties.getProperty(propName);
    }
    
    public Connection getConnection() throws SQLException {
        // Récupérer les paramètres depuis les variables d'environnement ou application.properties
        String dbName = getPropertyFromEnvAliases(new String[]{"DB_NAME", "POSTGRES_DB"}, "db.name");
        String dbHost = getProperty("DB_HOST", "db.host");
        String dbPort = getPropertyFromEnvAliases(new String[]{"DB_PORT", "POSTGRES_PORT"}, "db.port");
        String user = getPropertyFromEnvAliases(new String[]{"DB_USER", "POSTGRES_USER"}, "db.username");
        String password = getPropertyFromEnvAliases(new String[]{"DB_PASSWORD", "POSTGRES_PASSWORD"}, "db.password");
        
        // Si pas de host/port dans les propriétés ou env, utiliser l'URL complète
        String url;
        if (dbHost != null && !dbHost.isEmpty()) {
            url = String.format("jdbc:postgresql://%s:%s/%s", 
                               dbHost, 
                               dbPort != null ? dbPort : "5432", 
                               dbName != null ? dbName : "controltower");
        } else {
            // Fallback sur l'URL complète depuis application.properties
            url = properties.getProperty("db.url");
        }
        
        try {
            Class.forName(properties.getProperty("db.driver"));
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver de base de données non trouvé", e);
        }
        
        System.out.println("[DB] Connexion a la base de donnees:");
        System.out.println("   URL: " + url);
        System.out.println("   User: " + user);
        
        return DriverManager.getConnection(url, user, password);
    }
}
