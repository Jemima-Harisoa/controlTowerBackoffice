document.addEventListener('DOMContentLoaded', function() {
    // Gestion de l'ouverture/fermeture des sous-menus
    const menuItems = document.querySelectorAll('.sidebar-menu > li > a');
    
    menuItems.forEach(item => {
        item.addEventListener('click', function(e) {
            const submenu = this.nextElementSibling;
            const parentLi = this.parentElement;
            
            if (submenu && submenu.classList.contains('submenu')) {
                e.preventDefault();
                
                // Fermer les autres sous-menus
                document.querySelectorAll('.sidebar-menu > li').forEach(li => {
                    if (li !== parentLi) {
                        li.classList.remove('open');
                        const sub = li.querySelector('.submenu');
                        if (sub) sub.style.display = 'none';
                    }
                });
                
                // Basculer l'état du sous-menu actuel
                parentLi.classList.toggle('open');
                submenu.style.display = parentLi.classList.contains('open') ? 'block' : 'none';
            }
        });
    });
    
    // Gestion du bouton de menu pour mobile
    const menuToggle = document.querySelector('.menu-toggle');
    const sidebar = document.querySelector('.sidebar');
    
    if (menuToggle) {
        menuToggle.addEventListener('click', function() {
            sidebar.classList.toggle('active');
        });
    }
    
    // Fermer la sidebar lors d'un clic en dehors sur mobile
    document.addEventListener('click', function(e) {
        if (window.innerWidth <= 768) {
            if (!sidebar.contains(e.target) && !menuToggle.contains(e.target) && sidebar.classList.contains('active')) {
                sidebar.classList.remove('active');
            }
        }
    });
});
