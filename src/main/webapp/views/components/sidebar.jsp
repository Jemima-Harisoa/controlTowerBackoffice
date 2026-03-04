<%@ page pageEncoding="UTF-8" %>
<%-- 
    sidebar.jsp - Barre laterale de navigation
    =============================================
    Inclus via <%@ include %> dans header.jsp (compile-time)
    
    Liens de navigation : seuls les liens avec des controleurs existants sont gardes.
    Les liens /reports/* et /settings/* ont ete retires (pas de controleurs).
    
    Icones : Font Awesome 5 (charge dans header.jsp via CDN)
--%>
<div class="sidebar">
    
    <!-- LOGO -->
    <div class="sidebar-header">
        <div class="logo">
            <i class="fas fa-building logo-icon"></i>
            <span class="logo-text">Control Tower</span>
        </div>
    </div>

    <!-- MENU -->
    <ul class="sidebar-menu">

        <!-- DASHBOARD -->
        <li data-page="dashboard">
            <a href="${pageContext.request.contextPath}/welcome">
                <i class="fas fa-tachometer-alt"></i>
                <span>Dashboard</span>
            </a>
        </li>

        <!-- RESERVATIONS -->
        <li data-page="reservations">
            <a href="#">
                <i class="fas fa-calendar-alt"></i>
                <span>R&#233;servations</span>
                <i class="fas fa-chevron-down submenu-arrow"></i>
            </a>
            <ul class="submenu">
                <li>
                    <a href="${pageContext.request.contextPath}/reservations">
                        <i class="fas fa-list"></i> Liste des r&#233;servations
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/reservations/create">
                        <i class="fas fa-plus"></i> Nouvelle r&#233;servation
                    </a>
                </li>
            </ul>
        </li>

        <!-- HOTELS -->
        <li data-page="hotels">
            <a href="#">
                <i class="fas fa-hotel"></i>
                <span>H&#244;tels</span>
                <i class="fas fa-chevron-down submenu-arrow"></i>
            </a>
            <ul class="submenu">
                <li>
                    <a href="${pageContext.request.contextPath}/hotels/list">
                        <i class="fas fa-list"></i> Liste des h&#244;tels
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/hotels/create">
                        <i class="fas fa-plus"></i> Ajouter un h&#244;tel
                    </a>
                </li>
            </ul>
        </li>

        <!-- CLIENTS -->
        <li data-page="clients">
            <a href="#">
                <i class="fas fa-users"></i>
                <span>Clients</span>
                <i class="fas fa-chevron-down submenu-arrow"></i>
            </a>
            <ul class="submenu">
                <li>
                    <a href="${pageContext.request.contextPath}/clients/list">
                        <i class="fas fa-list"></i> Liste des clients
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/clients/create">
                        <i class="fas fa-plus"></i> Ajouter un client
                    </a>
                </li>
            </ul>
        </li>

    </ul>
</div>
