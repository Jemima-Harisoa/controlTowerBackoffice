<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consultation des R&#233;servations - Control Tower</title>
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f0f2f5;
            color: #333;
        }
        
        /* === HEADER === */
        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px 40px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        
        .page-header h1 {
            font-size: 28px;
            margin-bottom: 5px;
        }
        
        .page-header p {
            opacity: 0.85;
            font-size: 14px;
        }
        
        .header-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .btn-backoffice {
            padding: 8px 20px;
            background: rgba(255,255,255,0.2);
            color: white;
            text-decoration: none;
            border-radius: 6px;
            font-size: 14px;
            transition: background 0.3s;
        }
        
        .btn-backoffice:hover {
            background: rgba(255,255,255,0.35);
        }
        
        /* === CONTAINER === */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 30px 20px;
        }
        
        /* === FILTRES === */
        .filters-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        
        .filters-card h3 {
            margin-bottom: 15px;
            color: #555;
            font-size: 16px;
        }
        
        .filters-row {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        
        .filter-group {
            flex: 1;
            min-width: 200px;
        }
        
        .filter-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            font-size: 13px;
            color: #666;
        }
        
        .filter-group input,
        .filter-group select {
            width: 100%;
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
        }
        
        .btn-filter:hover {
            background: #5a6fd6;
        }
        
        .btn-reset {
            padding: 10px 24px;
            background: #6c757d;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            transition: background 0.3s;
        }
        
        .btn-reset:hover {
            background: #5a6268;
        }
        
        /* === STATS === */
        .stats-bar {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-item {
            background: white;
            padding: 15px 25px;
            border-radius: 8px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.06);
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .stat-item i {
            font-size: 24px;
            color: #667eea;
        }
        
        .stat-item .stat-value {
            font-size: 22px;
            font-weight: 700;
            color: #333;
        }
        
        .stat-item .stat-label {
            font-size: 12px;
            color: #888;
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
        
        /* === LOADING === */
        .loading {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        
        .loading i {
            font-size: 40px;
            animation: spin 1s linear infinite;
            margin-bottom: 15px;
            display: block;
        }
        
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        
        /* === EMPTY STATE === */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        
        .empty-state i {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.4;
        }
        
        .empty-state h3 {
            color: #666;
            margin-bottom: 8px;
        }
        
        /* === ERROR === */
        .error-state {
            text-align: center;
            padding: 40px 20px;
            color: #dc3545;
            background: #fff5f5;
            border-radius: 8px;
            margin: 20px 0;
        }

        .icon-confirmed {
            color: #28a745;
        }

        .icon-pending {
            color: #ffc107;
        }
        
        /* === RESPONSIVE === */
        @media (max-width: 768px) {
            .page-header { padding: 20px; }
            .page-header h1 { font-size: 22px; }
            .filters-row { flex-direction: column; }
            .filter-group { min-width: 100%; }
            .stats-bar { flex-direction: column; }
            .container { padding: 15px; }
            .reservations-table { font-size: 12px; }
            .reservations-table th,
            .reservations-table td { padding: 10px 8px; }
        }
    </style>
</head>
<body>
    <!-- En-t&#234;te -->
    <div class="page-header">
        <div class="header-nav">
            <div>
                <h1><i class="fas fa-calendar-alt"></i> Consultation des R&#233;servations</h1>
                <p>Visualisez les r&#233;servations en temps r&#233;el</p>
            </div>
            <a href="${pageContext.request.contextPath}/login" class="btn-backoffice">
                <i class="fas fa-lock"></i> Acc&#232;s Backoffice
            </a>
        </div>
    </div>
    
    <div class="container">
        <!-- Filtres -->
        <div class="filters-card">
            <h3><i class="fas fa-filter"></i> Filtrer les r&#233;servations</h3>
            <div class="filters-row">
                <div class="filter-group">
                    <label for="filterDate">Date d'arriv&#233;e</label>
                    <input type="date" id="filterDate">
                </div>
                <div class="filter-group">
                    <label for="filterHotel">H&#244;tel</label>
                    <select id="filterHotel">
                        <option value="">Tous les h&#244;tels</option>
                        <c:forEach items="${hotels}" var="hotel">
                            <option value="${hotel.id}">${hotel.nom} - ${hotel.ville}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="filter-actions">
                    <button class="btn-filter" onclick="applyFilters()">
                        <i class="fas fa-search"></i> Rechercher
                    </button>
                    <button class="btn-reset" onclick="resetFilters()">
                        <i class="fas fa-undo"></i> R&#233;initialiser
                    </button>
                </div>
            </div>
        </div>
        
        <!-- Statistiques -->
        <div class="stats-bar" id="statsBar">
            <div class="stat-item">
                <i class="fas fa-calendar-check"></i>
                <div>
                    <div class="stat-value" id="statTotal">-</div>
                    <div class="stat-label">R&#233;servations</div>
                </div>
            </div>
            <div class="stat-item">
                <i class="fas fa-check-circle icon-confirmed"></i>
                <div>
                    <div class="stat-value" id="statConfirmed">-</div>
                    <div class="stat-label">Confirm&#233;es</div>
                </div>
            </div>
            <div class="stat-item">
                <i class="fas fa-clock icon-pending"></i>
                <div>
                    <div class="stat-value" id="statPending">-</div>
                    <div class="stat-label">En attente</div>
                </div>
            </div>
        </div>
        
        <!-- Tableau des réservations -->
        <div class="table-card">
            <div id="tableContent">
                <div class="loading">
                    <i class="fas fa-spinner"></i>
                    <p>Chargement des r&#233;servations...</p>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        const API_BASE = '${pageContext.request.contextPath}/api/reservations';
        
        // Chargement initial
        document.addEventListener('DOMContentLoaded', function() {
            loadReservations();
        });
        
        /**
         * Charge les réservations depuis l'API REST
         */
        function loadReservations(params) {
            const tableContent = document.getElementById('tableContent');
            tableContent.innerHTML = '<div class="loading"><i class="fas fa-spinner"></i><p>Chargement...</p></div>';
            
            let url = API_BASE;
            if (params) {
                const queryParams = new URLSearchParams();
                if (params.date) queryParams.append('date', params.date);
                if (params.hotelId) queryParams.append('hotelId', params.hotelId);
                const qs = queryParams.toString();
                if (qs) url += '?' + qs;
            }
            
            fetch(url)
                .then(function(response) {
                    if (!response.ok) throw new Error('Erreur serveur ' + response.status);
                    return response.json();
                })
                .then(function(apiResponse) {
                    if (apiResponse.status === 'success') {
                        renderTable(apiResponse.data);
                        updateStats(apiResponse.data);
                    } else {
                        showError(apiResponse.message || 'Erreur inconnue');
                    }
                })
                .catch(function(error) {
                    console.error('Erreur:', error);
                    showError('Impossible de charger les r\u00e9servations : ' + error.message);
                });
        }
        
        /**
         * Génère le tableau HTML à partir des données
         */
        function renderTable(reservations) {
            const tableContent = document.getElementById('tableContent');
            
            if (!reservations || reservations.length === 0) {
                tableContent.innerHTML = 
                    '<div class="empty-state">' +
                    '  <i class="fas fa-calendar-times"></i>' +
                    '  <h3>Aucune r\u00e9servation trouv\u00e9e</h3>' +
                    '  <p>Aucune r\u00e9servation ne correspond aux crit\u00e8res de recherche.</p>' +
                    '</div>';
                return;
            }
            
            var html = '<table class="reservations-table">';
            html += '<thead><tr>';
            html += '<th>Client</th>';
            html += '<th>Email</th>';
            html += '<th>Date d\'arriv\u00e9e</th>';
            html += '<th>Heure</th>';
            html += '<th>Personnes</th>';
            html += '<th>H\u00f4tel</th>';
            html += '<th>Statut</th>';
            html += '</tr></thead>';
            html += '<tbody>';
            
            for (var i = 0; i < reservations.length; i++) {
                var r = reservations[i];
                var badgeClass = r.confirmed ? 'badge-success' : 'badge-warning';
                var badgeText = r.confirmed ? 'Confirm\u00e9e' : 'En attente';
                
                html += '<tr>';
                html += '<td><strong>' + escapeHtml(r.nomFormate) + '</strong></td>';
                html += '<td>' + escapeHtml(r.email) + '</td>';
                html += '<td>' + escapeHtml(r.dateAffichee) + '</td>';
                html += '<td>' + escapeHtml(r.heureAffichee) + '</td>';
                html += '<td><strong>' + r.nombrePersonnes + '</strong> pers.</td>';
                html += '<td>' + escapeHtml(r.nomHotel) + '</td>';
                html += '<td><span class="badge ' + badgeClass + '">' + badgeText + '</span></td>';
                html += '</tr>';
            }
            
            html += '</tbody></table>';
            tableContent.innerHTML = html;
        }
        
        /**
         * Met à jour les statistiques
         */
        function updateStats(reservations) {
            var total = reservations ? reservations.length : 0;
            var confirmed = 0;
            
            if (reservations) {
                for (var i = 0; i < reservations.length; i++) {
                    if (reservations[i].confirmed) confirmed++;
                }
            }
            
            document.getElementById('statTotal').textContent = total;
            document.getElementById('statConfirmed').textContent = confirmed;
            document.getElementById('statPending').textContent = total - confirmed;
        }
        
        /**
         * Applique les filtres sélectionnés
         */
        function applyFilters() {
            var params = {};
            var date = document.getElementById('filterDate').value;
            var hotelId = document.getElementById('filterHotel').value;
            
            if (date) params.date = date;
            if (hotelId) params.hotelId = hotelId;
            
            loadReservations(params);
        }
        
        /**
         * Réinitialise les filtres
         */
        function resetFilters() {
            document.getElementById('filterDate').value = '';
            document.getElementById('filterHotel').value = '';
            loadReservations();
        }
        
        /**
         * Échappe le HTML pour éviter les injections XSS
         */
        function escapeHtml(text) {
            if (!text) return '';
            var div = document.createElement('div');
            div.appendChild(document.createTextNode(text));
            return div.innerHTML;
        }
        
        /**
         * Affiche un message d'erreur
         */
        function showError(message) {
            document.getElementById('tableContent').innerHTML = 
                '<div class="error-state">' +
                '  <i class="fas fa-exclamation-triangle"></i>' +
                '  <h3>Erreur</h3>' +
                '  <p>' + escapeHtml(message) + '</p>' +
                '</div>';
        }
    </script>
</body>
</html>
