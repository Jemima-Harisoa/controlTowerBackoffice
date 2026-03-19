<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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

    /* === SPRINT 4 : Temps d'attente et regroupement === */
    .wait-time-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        border-radius: 12px;
        font-size: 13px;
        font-weight: 600;
        background: #fff3cd;
        color: #856404;
        border: 1px solid #ffeaa7;
        white-space: nowrap;
        transition: all 0.3s;
    }

    .wait-time-badge:hover {
        box-shadow: 0 2px 8px rgba(133, 100, 4, 0.15);
    }

    .wait-time-badge.wait-time-zero {
        background: #e8f5e9;
        color: #2e7d32;
        border-color: #c8e6c9;
    }

    .wait-time-badge i {
        font-size: 12px;
    }

    .departure-time {
        display: inline-block;
        padding: 6px 10px;
        border-radius: 6px;
        background: #e3f2fd;
        color: #1565c0;
        font-weight: 600;
        font-size: 13px;
        border: 1px solid #bbdefb;
    }

    .reservation-text {
        display: block;
        word-break: break-word;
        overflow-wrap: break-word;
        max-width: 200px;
    }

    .text-muted-sm {
        color: #999;
        font-size: 12px;
    }

    /* === RESPONSIVE DESIGN === */
    .hide-mobile {
        display: table-cell;
    }

    .hide-tablet {
        display: table-cell;
    }

    .hide-desktop {
        display: none;
    }

    @media (max-width: 1200px) {
        .hide-tablet {
            display: none;
        }

        .data-table {
            font-size: 12px;
        }

        .data-table td,
        .data-table th {
            padding: 10px 12px;
        }

        .filter-grid {
            grid-template-columns: repeat(2, 1fr);
        }
    }

    @media (max-width: 768px) {
        .hide-mobile {
            display: none;
        }

        .hide-desktop {
            display: table-cell;
        }

        .data-table {
            font-size: 11px;
        }

        .data-table td,
        .data-table th {
            padding: 8px 6px;
        }

        .wait-time-badge {
            padding: 4px 8px;
            font-size: 11px;
            gap: 4px;
        }

        .departure-time {
            padding: 4px 8px;
            font-size: 11px;
        }

        .reservation-text {
            max-width: 150px;
        }

        .filter-grid {
            grid-template-columns: 1fr;
        }

        .page-title {
            font-size: 20px;
        }
    }

    @media (max-width: 480px) {
        .data-table {
            font-size: 10px;
        }

        .data-table td,
        .data-table th {
            padding: 6px 4px;
        }

        .page-title {
            font-size: 18px;
        }

        .wait-time-badge {
            padding: 3px 6px;
            font-size: 10px;
        }

        .departure-time {
            padding: 3px 6px;
            font-size: 10px;
        }

        .reservation-text {
            max-width: 120px;
            font-size: 10px;
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
                        <option value="${v.id}" <c:if test="${filterVehiculeId == v.id}">selected</c:if>>
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
                        <th><span title="Plage horaire du groupe avec temps d'attente">Temps attente</span></th>
                        <th><span title="Heure départ ajustée">Heure départ</span></th>
                        <th class="hide-mobile">Passagers</th>
                        <th class="hide-tablet">Capacité</th>
                        <th class="hide-mobile">Places libres</th>
                        <th class="hide-tablet">Distance (km)</th>
                        <th class="hide-tablet">Durée estimée</th>
                        <th class="hide-mobile">Départ</th>
                        <th class="hide-desktop">Arrivée</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${details}" var="detail">
                        <tr>
                            <td><strong>Véhicule #${detail.vehiculeId}</strong></td>
                            <td>${detail.dateArrivee}</td>
                            <td>${detail.heureArrivee}</td>
                            <td>
                                <em class="reservation-text">${detail.reservationClient}</em>
                            </td>
                            <td>
                                <c:if test="${detail.tempsAttenteGroupeMinutes > 0}">
                                    <span class="wait-time-badge" title="${detail.plageHeuresGroupe}">
                                        <i class="fas fa-hourglass-half"></i> ${detail.tempsAttenteGroupeMinutes} min
                                    </span>
                                </c:if>
                                <c:if test="${detail.tempsAttenteGroupeMinutes == 0}">
                                    <span class="wait-time-badge wait-time-zero">Seul</span>
                                </c:if>
                            </td>
                            <td>
                                <c:if test="${not empty detail.heureDeprtAjustee}">
                                    <span class="departure-time">${detail.heureDeprtAjustee}</span>
                                </c:if>
                                <c:if test="${empty detail.heureDeprtAjustee}">
                                    <span class="text-muted-sm">-</span>
                                </c:if>
                            </td>
                            <td class="hide-mobile">-</td>
                            <td class="hide-tablet">${detail.capaciteVehicule} pax</td>
                            <td class="hide-mobile"><strong>${detail.placesLibres}</strong></td>
                            <td class="hide-tablet">
                                <span style="font-weight: 700;">
                                    <fmt:formatNumber value="${detail.distanceEstimee}" maxFractionDigits="2" minFractionDigits="2" />
                                    km
                                </span>
                            </td>
                            <td class="hide-tablet"><span style="font-weight: 700; color: #0066cc;">${detail.dureeEstimee != null && !detail.dureeEstimee.isEmpty() ? detail.dureeEstimee : 'N/A'}</span></td>
                            <td class="hide-mobile">${detail.pointsDepart}</td>
                            <td class="hide-desktop">${detail.pointsArrivee}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/views/components/footer.jsp" %>
