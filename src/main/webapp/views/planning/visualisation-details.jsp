<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="/views/components/header.jsp" %>

<style>
    .panel {
        background: white;
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }

    .title {
        margin-top: 0;
        color: #1f2d3d;
    }

    .meta-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(160px, 1fr));
        gap: 10px;
    }

    .meta-box {
        border: 1px solid #ececec;
        border-radius: 8px;
        padding: 12px;
        background: #fafbff;
    }

    .meta-label {
        font-size: 12px;
        color: #666;
        margin-bottom: 5px;
        font-weight: 600;
        text-transform: uppercase;
    }

    .meta-value {
        font-size: 15px;
        color: #2f3b52;
        font-weight: 700;
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

    .data-table {
        width: 100%;
        border-collapse: collapse;
    }

    .data-table th,
    .data-table td {
        border-bottom: 1px solid #eee;
        padding: 12px;
        text-align: left;
    }

    .data-table thead {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }

    .data-table th {
        color: white;
        font-size: 13px;
        text-transform: uppercase;
    }

    .btn-back {
        display: inline-block;
        padding: 10px 14px;
        border-radius: 6px;
        background: #6c757d;
        color: white;
        text-decoration: none;
        font-weight: 600;
    }
</style>

<div class="panel">
    <h2 class="title">Détail du trajet groupé</h2>
    <a class="btn-back" href="${pageContext.request.contextPath}/planning/visualisation">Retour à la visualisation</a>
</div>

<c:choose>
    <c:when test="${empty groupe}">
        <div class="panel">Aucun groupe trouvé pour ce véhicule et ce créneau.</div>
    </c:when>
    <c:otherwise>
        <div class="panel">
            <div class="meta-grid">
                <div class="meta-box">
                    <div class="meta-label">Véhicule</div>
                    <div class="meta-value">${groupe.vehiculeImmatriculation}</div>
                </div>
                <div class="meta-box">
                    <div class="meta-label">Date</div>
                    <div class="meta-value">${groupe.dateArrivee}</div>
                </div>
                <div class="meta-box">
                    <div class="meta-label">Heure</div>
                    <div class="meta-value">${groupe.heureArrivee}</div>
                </div>
                <div class="meta-box">
                    <div class="meta-label">Passagers</div>
                    <div class="meta-value">${groupe.nombrePassagersTotal}</div>
                </div>
                <div class="meta-box">
                    <div class="meta-label">Capacité</div>
                    <div class="meta-value">${groupe.capaciteVehicule}</div>
                </div>
                <div class="meta-box">
                    <div class="meta-label">Places libres</div>
                    <div class="meta-value">${groupe.placesLibres}</div>
                </div>
                <div class="meta-box">
                    <div class="meta-label">Distance totale</div>
                    <div class="meta-value">${groupe.distanceTotale} km</div>
                </div>
                <div class="meta-box">
                    <div class="meta-label">Durée estimée</div>
                    <div class="meta-value">${groupe.dureeEstimee}</div>
                </div>
                <div class="meta-box">
                    <div class="meta-label">Carburant</div>
                    <div class="meta-value">${groupe.typeCarburantVehicule}</div>
                </div>
            </div>
        </div>

        <div class="panel">
            <h3>Réservations assignées</h3>
            <div class="chips">
                <c:forEach items="${groupe.clients}" var="client">
                    <span class="chip">${client}</span>
                </c:forEach>
            </div>
        </div>

        <div class="panel">
            <h3>Détail des réservations du groupe</h3>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Client</th>
                        <th>Passagers</th>
                        <th>Lieu départ</th>
                        <th>Lieu arrivée</th>
                        <th>Distance</th>
                        <th>Durée</th>
                        <th>Statut</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${plannings}" var="p">
                        <tr>
                            <td>${p.nomClient}</td>
                            <td>${p.nombrePersonnes}</td>
                            <td>${p.lieuDepart}</td>
                            <td>${p.lieuArrivee}</td>
                            <td>${p.distance} km</td>
                            <td>${p.dureeEstimee}</td>
                            <td>${p.statut}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:otherwise>
</c:choose>

<%@ include file="/views/components/footer.jsp" %>
