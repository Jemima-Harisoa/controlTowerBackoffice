<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="model.Reservation, model.Vehicule, model.PlanningTrajet" %>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Détails du Trajet - Control Tower</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <style>
        .details-container {
            max-width: 900px;
            margin: 2rem auto;
            padding: 2rem;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .details-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            border-bottom: 2px solid #f0f0f0;
            padding-bottom: 1rem;
        }

        .details-header h1 {
            margin: 0;
            color: #333;
            font-size: 1.8rem;
        }

        .status-badge {
            display: inline-block;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: bold;
            font-size: 0.85rem;
            text-transform: uppercase;
        }

        .status-badge.planifie {
            background-color: #ffc107;
            color: #333;
        }

        .status-badge.valide {
            background-color: #28a745;
            color: white;
        }

        .status-badge.encours {
            background-color: #007bff;
            color: white;
        }

        .details-section {
            margin-bottom: 2rem;
        }

        .section-title {
            color: #333;
            font-size: 1.2rem;
            font-weight: bold;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #007bff;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
        }

        .info-item {
            background: #f9f9f9;
            padding: 1rem;
            border-radius: 6px;
            border-left: 4px solid #007bff;
        }

        .info-label {
            color: #666;
            font-size: 0.85rem;
            text-transform: uppercase;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }

        .info-value {
            color: #333;
            font-size: 1.1rem;
            word-break: break-word;
        }

        .route-visualization {
            background: #f0f0f0;
            padding: 1.5rem;
            border-radius: 6px;
            text-align: center;
            margin: 1.5rem 0;
        }

        .route-item {
            display: inline-block;
            padding: 1rem 1.5rem;
            background: white;
            border-radius: 4px;
            margin: 0 0.5rem;
            font-weight: bold;
        }

        .route-arrow {
            display: inline-block;
            margin: 0 1rem;
            font-size: 1.5rem;
            color: #007bff;
        }

        .distance-duration {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-top: 1rem;
        }

        .distance-card, .duration-card {
            background: white;
            padding: 1.5rem;
            border-radius: 6px;
            text-align: center;
            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
        }

        .distance-card i, .duration-card i {
            font-size: 2rem;
            color: #007bff;
            margin-bottom: 0.5rem;
        }

        .distance-value, .duration-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: #333;
        }

        .distance-label, .duration-label {
            color: #666;
            font-size: 0.9rem;
            margin-top: 0.5rem;
        }

        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 2px solid #f0f0f0;
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 6px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.95rem;
        }

        .btn-primary {
            background-color: #007bff;
            color: white;
        }

        .btn-primary:hover {
            background-color: #0056b3;
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #545b62;
        }

        .btn-success {
            background-color: #28a745;
            color: white;
        }

        .btn-success:hover {
            background-color: #218838;
        }

        .btn-danger {
            background-color: #dc3545;
            color: white;
        }

        .btn-danger:hover {
            background-color: #c82333;
        }

        .error-alert {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 1rem;
            border-radius: 6px;
            margin-bottom: 1.5rem;
        }

        .success-alert {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
            padding: 1rem;
            border-radius: 6px;
            margin-bottom: 1.5rem;
        }

        .empty-state {
            text-align: center;
            padding: 2rem;
            color: #999;
        }

        .empty-state i {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: #ddd;
        }

        @media (max-width: 768px) {
            .details-container {
                margin: 0;
                border-radius: 0;
            }

            .details-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }

            .route-item {
                display: block;
                margin: 0.5rem 0;
            }

            .route-arrow {
                transform: rotate(90deg);
            }

            .distance-duration {
                grid-template-columns: 1fr;
            }

            .action-buttons {
                flex-direction: column;
            }

            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="main-container">
        <%@ include file="../components/sidebar.jsp" %>

        <div class="content">
            <div class="details-container">
                <!-- Message d'erreur -->
                <c:if test="${not empty erreur}">
                    <div class="error-alert">
                        <i class="fas fa-exclamation-circle"></i>
                        <strong>Erreur :</strong> ${erreur}
                    </div>
                </c:if>

                <!-- Message de succès -->
                <c:if test="${not empty succes}">
                    <div class="success-alert">
                        <i class="fas fa-check-circle"></i>
                        <strong>Succès :</strong> ${succes}
                    </div>
                </c:if>

                <!-- En-tête -->
                <c:if test="${not empty planning}">
                    <div class="details-header">
                        <h1>
                            <i class="fas fa-map-marked-alt"></i>
                            Détails du Trajet
                        </h1>
                        <div class="status-badge ${planning.statut == 'VALIDE' ? 'valide' : planning.statut == 'ENCOURS' ? 'encours' : 'planifie'}">
                            ${planning.statut}
                        </div>
                    </div>

                    <!-- Section Réservation -->
                    <div class="details-section">
                        <div class="section-title">
                            <i class="fas fa-user-tie"></i>
                            Informations Client
                        </div>
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-label">Nom</div>
                                <div class="info-value">${reservation.nom} ${reservation.prenom}</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Nombre de Passagers</div>
                                <div class="info-value">${reservation.passager} personne(s)</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Date d'Arrivée</div>
                                <div class="info-value">${reservation.dateArrivee} à ${reservation.heureArrivee}</div>
                            </div>
                        </div>
                    </div>

                    <!-- Section Route -->
                    <div class="details-section">
                        <div class="section-title">
                            <i class="fas fa-route"></i>
                            Itinéraire
                        </div>
                        <div class="route-visualization">
                            <div class="route-item">
                                <i class="fas fa-map-pin"></i><br>
                                ${planning.lieuDepart}
                            </div>
                            <div class="route-arrow">
                                <i class="fas fa-arrow-right"></i>
                            </div>
                            <div class="route-item">
                                <i class="fas fa-map-pin"></i><br>
                                ${planning.lieuArrivee}
                            </div>
                        </div>

                        <div class="distance-duration">
                            <div class="distance-card">
                                <i class="fas fa-road"></i>
                                <div class="distance-value">${planning.distanceEstimee} km</div>
                                <div class="distance-label">Distance estimée</div>
                            </div>
                            <div class="duration-card">
                                <i class="fas fa-hourglass-half"></i>
                                <div class="duration-value">${planning.dureeEstimee}</div>
                                <div class="duration-label">Durée estimée</div>
                            </div>
                        </div>
                    </div>

                    <!-- Section Véhicule -->
                    <c:if test="${not empty vehicule}">
                        <div class="details-section">
                            <div class="section-title">
                                <i class="fas fa-car"></i>
                                Véhicule Assigné
                            </div>
                            <div class="info-grid">
                                <div class="info-item">
                                    <div class="info-label">Immatriculation</div>
                                    <div class="info-value">${vehicule.immatriculation}</div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">Marque & Modèle</div>
                                    <div class="info-value">${vehicule.marque} ${vehicule.modele}</div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">Année</div>
                                    <div class="info-value">${vehicule.annee}</div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">Type de Carburant</div>
                                    <div class="info-value">${vehicule.typeCarburant}</div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">Capacité</div>
                                    <div class="info-value">${vehicule.capacitePassagers} passagers</div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">État</div>
                                    <div class="info-value">
                                        <c:if test="${vehicule.available}">
                                            <span style="color: #28a745; font-weight: bold;">
                                                <i class="fas fa-check"></i> Disponible
                                            </span>
                                        </c:if>
                                        <c:if test="${!vehicule.available}">
                                            <span style="color: #dc3545; font-weight: bold;">
                                                <i class="fas fa-times"></i> Indisponible
                                            </span>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:if>
                    <c:if test="${empty vehicule}">
                        <div class="details-section">
                            <div class="empty-state">
                                <i class="fas fa-car"></i>
                                <p>Aucun véhicule assigné à ce trajet</p>
                            </div>
                        </div>
                    </c:if>

                    <!-- Section Planification -->
                    <div class="details-section">
                        <div class="section-title">
                            <i class="fas fa-calendar-check"></i>
                            Statut de Planification
                        </div>
                        <div class="info-grid">
                            <div class="info-item">
                                <div class="info-label">Statut Actuel</div>
                                <div class="info-value">
                                    <span class="status-badge ${planning.statut == 'VALIDE' ? 'valide' : planning.statut == 'ENCOURS' ? 'encours' : 'planifie'}">
                                        ${planning.statut}
                                    </span>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Date de Planification</div>
                                <div class="info-value">${planning.datePlanification}</div>
                            </div>
                        </div>
                    </div>

                    <!-- Boutons d'action -->
                    <div class="action-buttons">
                        <button class="btn btn-secondary" onclick="history.back();">
                            <i class="fas fa-arrow-left"></i> Retour à l'assignation
                        </button>
                        <button class="btn btn-primary" onclick="retournerAssignation();">
                            <i class="fas fa-tasks"></i> Gérer les assignations
                        </button>
                        <button class="btn btn-success" onclick="imprimerDetails();">
                            <i class="fas fa-print"></i> Imprimer les détails
                        </button>
                    </div>
                </c:if>

                <!-- État vide -->
                <c:if test="${empty planning}">
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <h2>Aucun planning trouvé</h2>
                        <p>Le trajet demandé n'existe pas ou n'a pas encore été planifié.</p>
                        <div class="action-buttons" style="justify-content: center; margin-top: 1.5rem;">
                            <button class="btn btn-primary" onclick="retournerAssignation();">
                                <i class="fas fa-arrow-left"></i> Retour aux assignations
                            </button>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <script>
        function retournerAssignation() {
            window.location.href = '${pageContext.request.contextPath}/planning/assignation';
        }

        function imprimerDetails() {
            window.print();
        }

        // Auto-fermer les alertes après 5 secondes
        document.addEventListener('DOMContentLoaded', function() {
            const alerts = document.querySelectorAll('.error-alert, .success-alert');
            alerts.forEach(alert => {
                setTimeout(() => {
                    alert.style.display = 'none';
                }, 5000);
            });
        });
    </script>
</body>
</html>
