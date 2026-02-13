<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container">
    <h1>Créer une réservation</h1>
    
    <c:if test="${not empty erreurs}">
        <div class="alert alert-danger">
            <ul>
                <c:forEach items="${erreurs}" var="erreur">
                    <li>${erreur}</li>
                </c:forEach>
            </ul>
        </div>
    </c:if>
    
    <c:if test="${not empty erreur}">
        <div class="alert alert-danger">${erreur}</div>
    </c:if>
    
    <form action="/reservations/create" method="post">
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="nom">Nom du client *</label>
                    <input type="text" id="nom" name="nom" class="form-control" value="${param.nom}" required>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" id="email" name="email" class="form-control" value="${param.email}" required>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="dateArrivee">Date d'arrivée *</label>
                    <input type="date" id="dateArrivee" name="dateArrivee" class="form-control" value="${param.dateArrivee}" required>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="form-group">
                    <label for="heure">Heure d'arrivée (HH:MM) *</label>
                    <input type="text" id="heure" name="heure" class="form-control" placeholder="14:30" value="${param.heure}" required>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="nombrePersonnes">Nombre de personnes *</label>
                    <input type="number" id="nombrePersonnes" name="nombrePersonnes" min="1" class="form-control" value="${param.nombrePersonnes}" required>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="form-group">
                    <label for="hotelId">Hôtel *</label>
                    <select id="hotelId" name="hotelId" class="form-control" required>
                        <option value="">Sélectionnez un hôtel</option>
                        <c:forEach items="${hotels}" var="hotel">
                            <option value="${hotel.id}" ${param.hotelId == hotel.id ? 'selected' : ''}>
                                ${hotel.nom} (${hotel.ville})
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
        </div>
        
        <div class="card mb-4">
            <div class="card-header">
                <h5>Informations complémentaires du client (optionnel)</h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="sexeId">Sexe</label>
                            <select id="sexeId" name="sexeId" class="form-control">
                                <option value="">Non spécifié</option>
                                <c:forEach items="${sexes}" var="sexe">
                                    <option value="${sexe.id}" ${param.sexeId == sexe.id ? 'selected' : ''}>
                                        ${sexe.libelle}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="typeId">Type de client</label>
                            <select id="typeId" name="typeId" class="form-control">
                                <option value="">Standard</option>
                                <c:forEach items="${typeClients}" var="typeClient">
                                    <option value="${typeClient.id}" ${param.typeId == typeClient.id ? 'selected' : ''}>
                                        ${typeClient.libelle}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="form-actions">
            <button type="submit" class="btn btn-primary">
                <i class="fas fa-save"></i> Enregistrer la réservation
            </button>
            <a href="/reservations" class="btn btn-secondary">
                <i class="fas fa-times"></i> Annuler
            </a>
        </div>
    </form>
</div>

<script>
// Script pour définir la date minimale à aujourd'hui
document.addEventListener('DOMContentLoaded', function() {
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('dateArrivee').setAttribute('min', today);
});
</script>
