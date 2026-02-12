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
    
    public Connection getConnection() throws SQLException {
        String url = properties.getProperty("db.url");
        String user = properties.getProperty("db.username");
        String password = properties.getProperty("db.password");
        
        try {
            Class.forName(properties.getProperty("db.driver"));
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver de base de données non trouvé", e);
        }
        
        return DriverManager.getConnection(url, user, password);
    }
}
