<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="sidebar">
    
    <!-- HEADER -->
    <div class="sidebar-header">
        <div class="logo">
            <span class="logo-icon">🏨</span>
            <span class="logo-text">Control Tower</span>
        </div>
    </div>

    <!-- MENU -->
    <ul class="sidebar-menu">

        <!-- DASHBOARD -->
        <li data-page="dashboard">
            <a href="${pageContext.request.contextPath}/dashboard">
                <i class="icon-dashboard">📊</i>
                <span>Dashboard</span>
            </a>
        </li>

        <!-- HOTELS -->
        <li data-page="hotels">
            <a href="#">
                <i class="icon-hotel">🏨</i>
                <span>Hôtels</span>
                <i class="icon-arrow-down">▼</i>
            </a>

            <ul class="submenu">
                <li data-page="hotels-list">
                    <a href="${pageContext.request.contextPath}/hotels/list">
                        📋 Liste des hôtels
                    </a>
                </li>

                <li data-page="hotels-create">
                    <a href="${pageContext.request.contextPath}/hotels/create">
                        ➕ Ajouter un hôtel
                    </a>
                </li>
            </ul>
        </li>

        <!-- RESERVATIONS -->
        <li data-page="reservations">
            <a href="#">
                📅 <span>Réservations</span>
                <i class="icon-arrow-down">▼</i>
            </a>

            <ul class="submenu">
                <li>
                    <a href="${pageContext.request.contextPath}/reservations/list">
                        📋 Liste des réservations
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/reservations/create">
                        ➕ Nouvelle réservation
                    </a>
                </li>
            </ul>
        </li>

        <!-- CLIENTS -->
        <li data-page="clients">
            <a href="#">
                👥 <span>Clients</span>
                <i class="icon-arrow-down">▼</i>
            </a>

            <ul class="submenu">
                <li>
                    <a href="${pageContext.request.contextPath}/clients/list">
                        📋 Liste des clients
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/clients/create">
                        ➕ Ajouter un client
                    </a>
                </li>
            </ul>
        </li>

        <!-- REPORTS -->
        <li data-page="reports">
            <a href="#">
                📈 <span>Rapports</span>
                <i class="icon-arrow-down">▼</i>
            </a>

            <ul class="submenu">
                <li>
                    <a href="${pageContext.request.contextPath}/reports/monthly">
                        📅 Rapport mensuel
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/reports/annual">
                        📅 Rapport annuel
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/reports/hotels">
                        🏨 Performance hôtels
                    </a>
                </li>
            </ul>
        </li>

        <!-- SETTINGS -->
        <li data-page="settings">
            <a href="#">
                ⚙️ <span>Paramètres</span>
                <i class="icon-arrow-down">▼</i>
            </a>

            <ul class="submenu">
                <li>
                    <a href="${pageContext.request.contextPath}/settings/profile">
                        👤 Mon profil
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/settings/users">
                        👥 Gestion utilisateurs
                    </a>
                </li>

                <li>
                    <a href="${pageContext.request.contextPath}/settings/database">
                        💾 Base de données
                    </a>
                </li>
            </ul>
        </li>

    </ul>
</div>
