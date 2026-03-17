package service;

import model.ParametreConfiguration;
import repository.ParametreConfigurationRepository;

/**
 * Service pour la gestion des paramètres de configuration
 */
public class ParametreConfigurationService {
    private ParametreConfigurationRepository paramRepository = new ParametreConfigurationRepository();

    /**
     * Récupérer tous les paramètres
     */
    public java.util.List<ParametreConfiguration> getAll() {
        return paramRepository.findAll();
    }

    /**
     * Récupérer un paramètre par clé
     */
    public ParametreConfiguration getParametre(String cle) {
        return paramRepository.findByCle(cle);
    }

    /**
     * Récupérer un paramètre en tant qu'entier
     */
    public int getParametreAsInt(String cle) {
        ParametreConfiguration param = getParametre(cle);
        return param != null ? param.getValeurAsInt() : 0;
    }

    /**
     * Récupérer un paramètre en tant que double
     */
    public double getParametreAsDouble(String cle) {
        ParametreConfiguration param = getParametre(cle);
        return param != null ? param.getValeurAsDouble() : 0.0;
    }

    /**
     * Récupérer un paramètre en tant que booléen
     */
    public boolean getParametreAsBoolean(String cle) {
        ParametreConfiguration param = getParametre(cle);
        return param != null && param.getValeurAsBoolean();
    }

    /**
     * Récupérer un paramètre en tant que String
     */
    public String getParametreAsString(String cle) {
        ParametreConfiguration param = getParametre(cle);
        return param != null ? param.getValeur() : "";
    }

    /**
     * Créer un nouveau paramètre
     */
    public void createParametre(ParametreConfiguration param) {
        paramRepository.create(param);
    }

    /**
     * Mettre à jour un paramètre
     */
    public void updateParametre(ParametreConfiguration param) {
        paramRepository.update(param);
    }

    /**
     * Mettre à jour la valeur d'un paramètre par sa clé
     */
    public void updateParametreValue(String cle, String valeur) {
        ParametreConfiguration param = getParametre(cle);
        if (param != null) {
            param.setValeur(valeur);
            updateParametre(param);
        }
    }

    /**
     * Supprimer un paramètre par sa clé
     */
    public void deleteParametre(String cle) {
        paramRepository.deleteByCle(cle);
    }
}
