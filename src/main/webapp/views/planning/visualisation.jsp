<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="/views/components/header.jsp" %>

<style>
    .page-section {
        background: white;
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }

    .page-title {
        margin: 0 0 10px;
        color: #1f2d3d;
    }

    .filter-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(180px, 1fr)) auto;
        gap: 10px;
        align-items: end;
    }

    .filter-grid label {
        display: block;
        font-size: 13px;
        color: #666;
        margin-bottom: 6px;
        font-weight: 600;
    }

    .filter-grid input,
    .filter-grid select {
        width: 100%;
        padding: 10px;
        border: 1px solid #d9d9d9;
        border-radius: 6px;
    }

    .btn {
        padding: 10px 14px;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        text-decoration: none;
        display: inline-block;
        font-weight: 600;
    }

    .btn-primary { background: #3f51b5; color: white; }
    .btn-secondary { background: #6c757d; color: white; }
    .btn-info { background: #17a2b8; color: white; }

    .data-table {
        width: 100%;
        border-collapse: collapse;
    }

    .data-table thead {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }

    .data-table th,
    .data-table td {
        padding: 12px;
        border-bottom: 1px solid #eee;
        text-align: left;
        vertical-align: top;
    }

    .data-table th {
        color: white;
        font-size: 13px;
        text-transform: uppercase;
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

    .empty {
        padding: 30px;
        text-align: center;
        color: #888;
    }

    @media (max-width: 900px) {
        .filter-grid {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="page-section">
    <h2 class="page-title">Visualisation des trajets groupés</h2>
    <p>Affichage des réservations regroupées par véhicule et créneau (date + heure).</p>
</div>

<div class="page-section">
    <form method="get" action="${pageContext.request.contextPath}/planning/visualisation">
        <div class="filter-grid">
            <div>
                <label for="date">Date d'arrivée</label>
                <input type="date" id="date" name="date" value="${filterDate}">
            </div>
            <div>
                <label for="heure">Heure d'arrivée</label>
                <input type="time" id="heure" name="heure" value="${filterHeure}">
            </div>
            <div>
                <label for="vehiculeId">Véhicule</label>
                <select id="vehiculeId" name="vehiculeId">
                    <option value="">Tous les véhicules</option>
                    <c:forEach items="${vehicules}" var="v">
                        <option value="${v.id}" <c:if test="${filterVehiculeId == v.id || filterVehiculeId == fn:toString(v.id)}">selected</c:if>>
                            ${v.immatriculation} - ${v.marque} ${v.modele}
                        </option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <button class="btn btn-primary" type="submit">Filtrer</button>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/planning/visualisation">Réinitialiser</a>
            </div>
        </div>
    </form>
</div>

<div class="page-section">
    <c:choose>
        <c:when test="${empty details}">
            <div class="empty">Aucun trajet à afficher.</div>
        </c:when>
        <c:otherwise>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Véhicule</th>
                        <th>Date</th>
                        <th>Heure</th>
                        <th>Réservation</th>
                        <th>Passagers</th>
                        <th>Capacité</th>
                        <th>Places libres</th>
                        <th>Distance (km)</th>
                        <th>Durée</th>
                        <th>Départ</th>
                        <th>Arrivée</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${details}" var="detail">
                        <tr>
                            <td>${detail.vehiculeId}</td>
                            <td>${detail.dateArrivee}</td>
                            <td>${detail.heureArrivee}</td>
                            <td>${detail.reservationClient}</td>
                            <td>-</td>
                            <td>${detail.capaciteVehicule}</td>
                            <td>${detail.placesLibres}</td>
                            <td>${detail.distanceEstimee}</td>
                            <td>${detail.dureeEstimee}</td>
                            <td>${detail.pointsDepart}</td>
                            <td>${detail.pointsArrivee}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/views/components/footer.jsp" %>
