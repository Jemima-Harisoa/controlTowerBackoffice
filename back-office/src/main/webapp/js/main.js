// Fonctions JavaScript générales pour l'application

document.addEventListener('DOMContentLoaded', function() {
    // Initialisation des tooltips Bootstrap si utilisés
    if (typeof $ !== 'undefined' && $.fn.tooltip) {
        $('[data-toggle="tooltip"]').tooltip();
    }
    
    // Confirmation avant suppression
    const deleteButtons = document.querySelectorAll('.btn-delete');
    deleteButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            if (!confirm('Êtes-vous sûr de vouloir supprimer cet élément ?')) {
                e.preventDefault();
            }
        });
    });
    
    // Formatage des dates si nécessaire
    const dateInputs = document.querySelectorAll('input[type="date"]');
    dateInputs.forEach(input => {
        if (input.value) {
            // Formatage de la date si nécessaire
            // À adapter selon vos besoins
        }
    });
    
    // Validation des formulaires
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            // Validation personnalisée si nécessaire
            // À adapter selon vos besoins
        });
    });
    
    // Messages de notification (toast)
    function showToast(message, type = 'info') {
        // Création et affichage d'un toast
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.textContent = message;
        
        document.body.appendChild(toast);
        
        // Suppression automatique après 3 secondes
        setTimeout(() => {
            toast.classList.add('show');
            setTimeout(() => {
                toast.classList.remove('show');
                setTimeout(() => {
                    document.body.removeChild(toast);
                }, 300);
            }, 3000);
        }, 100);
    }
    
    // Expose la fonction showToast globalement
    window.showToast = showToast;
});
