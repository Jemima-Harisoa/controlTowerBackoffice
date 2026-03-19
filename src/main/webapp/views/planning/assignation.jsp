<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- Page d'assignation des véhicules aux réservations : inclut header et footer automatiquement --%>
<%@ include file="/views/components/header.jsp" %>

<!-- CSS spécifique à cette page -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/reservation.css">

<style>
    .planning-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 25px;
    }

    .planning-header.sticky-actions {
        position: sticky;
        top: 10px;
        z-index: 1000;
        background: #f5f7fb;
        padding: 12px;
        border-radius: 10px;
        box-shadow: 0 4px 14px rgba(0,0,0,0.12);
    }
    
    .planning-header h2 {
        margin: 0;
        color: #333;
        font-size: 28px;
    }
    
    .btn-group {
        display: flex;
        gap: 10px;
    }
    
    .btn-primary {
        padding: 12px 24px;
        background: #007bff;
        color: white;
        text-decoration: none;
        border: none;
        border-radius: 6px;
        transition: all 0.3s;
        font-weight: 500;
        box-shadow: 0 2px 4px rgba(0,123,255,0.3);
        cursor: pointer;
    }
    
    .btn-primary:hover {
        background: #0056b3;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,123,255,0.4);
    }

    .btn-success {
        padding: 12px 24px;
        background: #28a745;
        color: white;
        text-decoration: none;
        border: none;
        border-radius: 6px;
        transition: all 0.3s;
        font-weight: 500;
        box-shadow: 0 2px 4px rgba(40,167,69,0.3);
        cursor: pointer;
    }

    .btn-success:hover {
        background: #218838;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(40,167,69,0.4);
    }

    .btn-warning {
        padding: 12px 24px;
        background: #ffc107;
        color: #333;
        text-decoration: none;
        border: none;
        border-radius: 6px;
        transition: all 0.3s;
        font-weight: 500;
        box-shadow: 0 2px 4px rgba(255,193,7,0.3);
        cursor: pointer;
    }

    .btn-warning:hover {
        background: #e0a800;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(255,193,7,0.4);
    }
    
    .filter-section {
        background: white;
        border-radius: 10px;
        padding: 25px;
        margin-bottom: 25px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }

    .filter-section.sticky-filter {
        position: sticky;
        top: 96px;
        z-index: 999;
    }

    .filter-section h3 {
        margin: 0 0 15px;
        color: #555;
        font-size: 16px;
    }

    .filter-row {
        display: grid;
        grid-template-columns: repeat(3, minmax(220px, 1fr)) auto;
        gap: 10px;
        align-items: flex-end;
    }

    .filter-group {
        min-width: 0;
    }

    .filter-group label {
        display: block;
        margin-bottom: 6px;
        font-weight: 600;
        color: #666;
        font-size: 13px;
    }

    .filter-group input,
    .filter-group select {
        width: 1.5in;
        min-width: 1.5in;
        max-width: 1.5in;
        padding: 10px 12px;
        border: 1px solid #ddd;
        border-radius: 6px;
        font-size: 14px;
        transition: border-color 0.3s;
    }

    .filter-group input:focus,
    .filter-group select:focus {
        border-color: #667eea;
        outline: none;
        box-shadow: 0 0 0 3px rgba(102,126,234,0.15);
    }

    .filter-actions {
        display: flex;
        gap: 10px;
        align-self: end;
        white-space: nowrap;
    }

    .btn-filter {
        padding: 10px 24px;
        background: #667eea;
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-size: 14px;
        font-weight: 500;
        transition: background 0.3s;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }

    .btn-filter:hover {
        background: #5a6fd6;
    }

    .btn-reset {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 10px 24px;
        background: #6c757d;
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-size: 14px;
        text-decoration: none;
        transition: background 0.3s;
    }

    .btn-reset:hover {
        background: #5a6268;
    }

    .btn-sm {
        padding: 6px 12px;
        border-radius: 4px;
        text-decoration: none;
        font-size: 13px;
        transition: all 0.3s;
        font-weight: 500;
    }

    .btn-info {
        background: #17a2b8;
        color: white;
        border: none;
        cursor: pointer;
    }

    .btn-info:hover {
        background: #138496;
    }

    .vehicules-section {
        background: white;
        padding: 20px;
        border-radius: 8px;
        margin-bottom: 25px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }

    .vehicules-section h3 {
        margin-top: 0;
        color: #333;
        font-size: 18px;
        margin-bottom: 15px;
    }

    .vehicules-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap: 15px;
    }

    .vehicule-card {
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        padding: 15px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        transition: all 0.3s;
        cursor: pointer;
    }

    .vehicule-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 16px rgba(0,0,0,0.2);
    }

    .vehicule-card.selected {
        border: 3px solid #ffc107;
        box-shadow: 0 0 0 4px rgba(255,193,7,0.3);
    }

    .vehicule-card h4 {
        margin: 0 0 10px;
        font-size: 16px;
        font-weight: 700;
    }

    .vehicule-info {
        font-size: 13px;
        margin-bottom: 5px;
    }

    .vehicule-info strong {
        display: inline-block;
        width: 80px;
    }

    .planning-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }

    .planning-table thead {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }

    .planning-table th {
        padding: 16px;
        text-align: left;
        color: white;
        font-weight: 600;
        font-size: 14px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .planning-table tbody tr {
        border-bottom: 1px solid #f0f0f0;
        transition: all 0.3s;
    }

    .planning-table tbody tr:hover {
        background-color: #f8f9fa;
        transform: scale(1.01);
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }

    .planning-table td {
        padding: 14px 16px;
        color: #555;
        font-size: 14px;
    }

    .badge {
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .badge-unassigned {
        background: #f8d7da;
        color: #721c24;
    }

    .badge-assigned {
        background: #d4edda;
        color: #155724;
    }

    .badge-validated {
        background: #cfe2ff;
        color: #084298;
    }

    .actions {
        display: flex;
        gap: 8px;
    }

    .stats-cards {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }

    .stat-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 20px;
        border-radius: 10px;
        color: white;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }

    .stat-card h3 {
        margin: 0 0 10px;
        font-size: 32px;
        font-weight: 700;
    }

    .stat-card p {
        margin: 0;
        opacity: 0.9;
        font-size: 14px;
    }

    .stat-card-unassigned {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    }

    .stat-card-vehicles {
        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
    }

    .alert {
        padding: 12px 20px;
        border-radius: 6px;
        margin-bottom: 20px;
    }

    .alert-success {
        background: #d4edda;
        color: #155724;
    }

    .alert-warning {
        background: #fff3cd;
        color: #856404;
    }

    .empty-state {
        text-align: center;
        padding: 60px 20px;
        color: #999;
        background: white;
        border-radius: 8px;
    }

    .empty-state-icon {
        font-size: 64px;
        margin-bottom: 20px;
        opacity: 0.3;
    }

    .empty-state h3 {
        margin: 0 0 10px;
        color: #666;
    }

    .empty-state p {
        margin: 0;
    }

    .select-vehicule-container {
        display: flex;
        gap: 10px;
        align-items: flex-end;
    }

    .select-vehicule-container select {
        flex: 1;
        padding: 10px 12px;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 14px;
    }

    .select-vehicule-container select:focus {
        outline: none;
        border-color: #007bff;
        box-shadow: 0 0 0 3px rgba(0,123,255,0.1);
    }

    .inline-form {
        display: inline;
    }

    .text-muted-sm {
        color: #999;
        font-size: 12px;
    }
    
    /* === TABLEAU === */
    .table-card {
        background: white;
        border-radius: 10px;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }
    
    .reservations-table {
        width: 100%;
        border-collapse: collapse;
    }
    
    .reservations-table thead {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }
    
    .reservations-table th {
        padding: 14px 16px;
        text-align: left;
        color: white;
        font-weight: 600;
        font-size: 13px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .reservations-table tbody tr {
        border-bottom: 1px solid #f0f0f0;
        transition: background 0.2s;
    }
    
    .reservations-table tbody tr:hover {
        background-color: #f8f9ff;
    }
    
    .reservations-table td {
        padding: 14px 16px;
        color: #555;
        font-size: 14px;
    }
    
    .badge {
        padding: 5px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
    }
    
    .badge-success {
        background: #d4edda;
        color: #155724;
    }
    
    .badge-warning {
        background: #fff3cd;
        color: #856404;
    }

    .chips {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
    }

    .chip {
        padding: 4px 10px;
        border-radius: 14px;
        font-size: 12px;
        font-weight: 600;
        background: #eef2ff;
        color: #3f51b5;
        border: 1px solid #dbe3ff;
    }

    .chip-place {
        background: #f1f8e9;
        color: #33691e;
        border: 1px solid #dcedc8;
    }

    .metric-inline {
        font-weight: 700;
        color: #2f3b52;
    }

    @media (max-width: 1080px) {
        .filter-row {
            grid-template-columns: repeat(2, minmax(220px, 1fr));
        }

        .filter-actions {
            grid-column: 1 / -1;
        }
    }

    @media (max-width: 720px) {
        .filter-row {
            grid-template-columns: 1fr;
        }

        .filter-actions {
            width: 100%;
            justify-content: stretch;
        }

        .btn-filter,
        .btn-reset {
            flex: 1;
            justify-content: center;
        }
    }
</style>

<!-- Statistiques -->
<div class="stats-cards">
    <div class="stat-card">
        <h3>${fn:length(reservations)}</h3>
        <p>Réservations à planifier</p>
    </div>

    <div class="stat-card stat-card-unassigned">
        <h3>${fn:length(planningGroupes)}</h3>
        <p>Trajets groupés (véhicule + créneau)</p>
    </div>

    <div class="stat-card stat-card-vehicles">
        <h3>${fn:length(vehicules)}</h3>
        <p>Véhicules disponibles</p>
    </div>
</div>

<!-- En-tête avec boutons d'action -->
<div class="planning-header sticky-actions">
    <h2><i class="fas fa-route"></i> Assignation des Véhicules</h2>
    <div class="btn-group">
        <button class="btn-success" href="#statutPlanningSection" onclick="genererPlanning()" title="Générer le planning automatiquement">
            <i class="fas fa-robot"></i> Générer Planning
        </button>
        <button class="btn-primary"  href="#statutPlanningSection" onclick="validerPlanning()" title="Valider le planning">
            <i class="fas fa-check-circle"></i> Valider Planning
        </button>
            <a class="btn-warning" href="#nonAssigneesSection" title="Aller à la section des réservations non assignées">
                <i class="fas fa-filter"></i> Non Assignées
            </a>
    </div>
</div>

<!-- Messages -->
<c:if test="${not empty message}">
    <div class="alert alert-success">
        ${message}
    </div>
</c:if>

<c:if test="${not empty erreur}">
    <div class="alert alert-warning">
        ${erreur}
    </div>
</c:if>

<!-- Filtres -->
<div class="filter-section sticky-filter">
    <h3><i class="fas fa-filter"></i> Filtrer les plannings</h3>
    <form method="get" action="${pageContext.request.contextPath}/planning/assignation#statutPlanningSection">
        <div class="filter-row">
            <div class="filter-group">
                <label for="filterDate">Date d'arrivée</label>
                <input type="date" id="filterDate" name="date" value="${filterDate}">
            </div>
            <div class="filter-group">
                <label for="filterHeure">Heure d'arrivée</label>
                <input type="time" id="filterHeure" name="heure" value="${filterHeure}">
            </div>
            <div class="filter-group">
                <label for="filterVehicule">Véhicule</label>
                <select id="filterVehicule" name="vehiculeId">
                    <option value="">-- Tous les véhicules --</option>
                    <c:forEach items="${vehicules}" var="v">
                        <option value="${v.id}" <c:if test="${v.id == filterVehiculeId}">selected</c:if>>
                            ${v.immatriculation} - ${v.marque} ${v.modele}
                        </option>
                    </c:forEach>
                </select>
            </div>
            <div class="filter-actions">
                <button type="submit" class="btn-filter">
                    <i class="fas fa-search"></i> Rechercher
                </button>
                <a href="${pageContext.request.contextPath}/planning/assignation#statutPlanningSection" class="btn-reset">
                    <i class="fas fa-undo"></i> Réinitialiser
                </a>
            </div>
        </div>
    </form>
</div>

<!-- Liste des véhicules disponibles -->
<div class="vehicules-section">
    <h3><i class="fas fa-van-shuttle"></i> Véhicules Disponibles</h3>
    <c:choose>
        <c:when test="${empty vehicules}">
            <div class="empty-state">
                <div class="empty-state-icon"><i class="fas fa-car"></i></div>
                <h3>Aucun véhicule disponible</h3>
                <p>Ajoutez des véhicules pour commencer à planifier les trajets</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="vehicules-grid">
                <c:forEach items="${vehicules}" var="vehicule">
                    <div class="vehicule-card" onclick="selectVehicule(${vehicule.id})" id="vehicule-${vehicule.id}">
                        <h4>${vehicule.immatriculation}</h4>
                        <div class="vehicule-info">
                            <strong>Marque:</strong> ${vehicule.marque} ${vehicule.modele}
                        </div>
                        <div class="vehicule-info">
                            <strong>Année:</strong> ${vehicule.annee}
                        </div>
                        <div class="vehicule-info">
                            <strong>Carburant:</strong> ${vehicule.typeCarburant}
                        </div>
                        <div class="vehicule-info">
                            <strong>Places:</strong> ${vehicule.capacitePassagers} personnes
                        </div>
                        <c:if test="${vehicule.available}">
                            <div class="badge badge-assigned" style="margin-top: 10px;">✓ Disponible</div>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<div class= "vehicules-section" id="nonAssigneesSection">  
    <h3><i class="fas fa-van-shuttle"></i> Réservation Non Assignée </h3>
    <!-- Tableau des réservations Non assignée -->
    <c:choose>
        <c:when test="${empty reservations}">
            <div class="empty-state">
                <div class="empty-state-icon"><i class="fas fa-clipboard-list"></i></div>
                <h3>Aucune réservation</h3>
                <p>Aucune réservation ne correspond aux critères actuels.</p>
            </div>
        </c:when>
        <c:otherwise>
            <table class="reservations-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Client</th>
                        <th>Email</th>
                        <th>Date d'arrivée</th>
                        <th>Heure</th>
                        <th>Personnes</th>
                        <th>Hôtel</th>
                        <th>Statut</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${reservations}" var="reservation">
                        <tr>
                            <td><strong>#${reservation.id}</strong></td>
                            <td>${reservation.nomFormate}</td>
                            <td>${reservation.email}</td>
                            <td>${reservation.dateAffichee}</td>
                            <td>${reservation.heureAffichee}</td>
                            <td>
                                <strong>${reservation.nombrePersonnes}</strong>
                                <span class="text-muted-sm">pers.</span>
                            </td>
                            <td>${reservation.nomHotel}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${reservation.confirmed}">
                                        <span class="badge badge-success"><i class="fas fa-check"></i> Confirmee</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-warning"><i class="fas fa-hourglass-half"></i> En attente</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</div>

<div class="vehicules-section" id="statutPlanningSection">
    <h3><i class="fas fa-list-check"></i> Statut de Planification Groupée des Trajets</h3>
    <c:choose>
        <c:when test="${empty planningGroupes}">
            <div class="empty-state">
                <div class="empty-state-icon"><i class="fas fa-route"></i></div>
                <h3>Aucun trajet planifié</h3>
                <p>Générez le planning pour voir le statut d'assignation des réservations et véhicules.</p>
            </div>
        </c:when>
        <c:otherwise>
            <table class="reservations-table">
                <thead>
                    <tr>
                        <th>Véhicule</th>
                        <th>Date arrivée</th>
                        <th>Heure arrivée</th>
                        <th>Réservations assignées</th>
                        <th>Passagers total</th>
                        <th>Capacité</th>
                        <th>Places libres</th>
                        <th>Départs</th>
                        <th>Arrivées</th>
                        <th>Distance totale</th>
                        <th>Durée estimée</th>
                        <th>Carburant</th>
                        <th>Statut</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${planningGroupes}" var="groupe">
                        <tr>
                            <td><strong>${groupe.vehiculeImmatriculation}</strong></td>
                            <td>${groupe.dateArrivee}</td>
                            <td>${groupe.heureArrivee}</td>
                            <td>
                                <div class="chips">
                                    <c:forEach items="${groupe.clients}" var="client">
                                        <span class="chip">${client}</span>
                                    </c:forEach>
                                </div>
                            </td>
                            <td><span class="metric-inline">${groupe.nombrePassagersTotal}</span></td>
                            <td>${groupe.capaciteVehicule}</td>
                            <td><span class="metric-inline">${groupe.placesLibres}</span></td>
                            <td>
                                <div class="chips">
                                    <c:forEach items="${groupe.pointsDepart}" var="pointDepart">
                                        <span class="chip chip-place">${pointDepart}</span>
                                    </c:forEach>
                                </div>
                            </td>
                            <td>
                                <div class="chips">
                                    <c:forEach items="${groupe.pointsArrivee}" var="pointArrivee">
                                        <span class="chip chip-place">${pointArrivee}</span>
                                    </c:forEach>
                                </div>
                            </td>
                            <td>${groupe.distanceTotale} km</td>
                            <td>${groupe.dureeEstimee}</td>
                            <td>${groupe.typeCarburantVehicule}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${groupe.statut == 'VALIDE'}">
                                        <span class="badge badge-success">${groupe.statut}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-warning">${groupe.statut}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</div>
<script>
    let selectedVehiculeId = null;

    function selectVehicule(vehiculeId) {
        // Déselectionner le précédent
        if (selectedVehiculeId) {
            document.getElementById('vehicule-' + selectedVehiculeId).classList.remove('selected');
        }
        
        // Sélectionner le nouveau
        selectedVehiculeId = vehiculeId;
        document.getElementById('vehicule-' + vehiculeId).classList.add('selected');
    }

    function genererPlanning() {
        if (confirm('Êtes-vous sûr de vouloir générer le planning automatiquement ?\nCette action assignera les réservations non assignées aux véhicules disponibles.')) {
            fetch('${pageContext.request.contextPath}/planning/assignation/generer', {
                method: 'POST'
            })
            .then(async response => {
                let data = null;
                try {
                    data = await response.json();
                } catch (e) {
                    data = null;
                }

                if (!response.ok) {
                    return {
                        ok: false,
                        message: (data && data.message) ? data.message : ('Erreur serveur (' + response.status + ')')
                    };
                }

                return {
                    ok: isApiSuccess(data),
                    message: (data && data.message) ? data.message : 'Planning généré.'
                };
            })
            .then(data => {
                if (data.ok) {
                    alert(data.message || 'Planning généré avec succès !');
                    location.href = '${pageContext.request.contextPath}/planning/assignation#statutPlanningSection';
                } else {
                    alert('Erreur: ' + (data && data.message ? data.message : 'Une erreur inconnue est survenue'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Erreur lors de la génération du planning');
            });
        }
    }

    function validerPlanning() {
        if (confirm('Êtes-vous sûr de vouloir valider le planning ?\nCette action finalisera toutes les assignations.')) {
            fetch('${pageContext.request.contextPath}/planning/assignation/valider', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            })
            .then(async response => {
                let data = null;
                try {
                    data = await response.json();
                } catch (e) {
                    data = null;
                }

                if (!response.ok) {
                    return {
                        ok: false,
                        message: (data && data.message) ? data.message : ('Erreur serveur (' + response.status + ')')
                    };
                }

                return {
                    ok: isApiSuccess(data),
                    message: (data && data.message) ? data.message : 'Planning validé.'
                };
            })
            .then(data => {
                if (data.ok) {
                    alert(data.message || 'Planning validé avec succès !');
                    location.href = '${pageContext.request.contextPath}/planning/assignation#statutPlanningSection';
                } else {
                    alert('Erreur: ' + (data && data.message ? data.message : 'Une erreur inconnue est survenue'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Erreur lors de la validation du planning');
            });
        }
    }

    function isApiSuccess(data) {
        if (!data) {
            return true;
        }

        if (typeof data.success !== 'undefined') {
            return !!data.success;
        }

        if (typeof data.status === 'string') {
            return data.status.toLowerCase() === 'success';
        }

        if (typeof data.code !== 'undefined') {
            return Number(data.code) >= 200 && Number(data.code) < 300;
        }

        return true;
    }

    function afficherNonAssignees() {
        // Filtrer pour afficher uniquement les réservations non assignées
        const rows = document.querySelectorAll('.planning-table tbody tr');
        let count = 0;
        rows.forEach(row => {
            const statut = row.querySelector('td:nth-child(8)');
            if (statut && statut.textContent.includes('Non assigné')) {
                row.style.display = '';
                count++;
            } else {
                row.style.display = 'none';
            }
        });
        alert('Affichage des ' + count + ' réservations non assignées');
    }
</script>

<%-- Footer commun : ferme le layout et charge les scripts --%>
<%@ include file="/views/components/footer.jsp" %>
