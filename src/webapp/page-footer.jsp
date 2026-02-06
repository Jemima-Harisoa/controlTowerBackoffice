        </div>
        
        <footer>
            <p>Product Manager &copy; 2024 | Framework MVC personnalisé | Jakarta EE</p>
            <p>Total produits en base: 
                <% 
                    if (request.getAttribute("totalProducts") != null) {
                        out.print(request.getAttribute("totalProducts"));
                    } else {
                        out.print("0");
                    }
                %>
            </p>
        </footer>
    </div>
    
    <script>
        // Validation basique des formulaires
        function validateForm(formId) {
            var form = document.getElementById(formId);
            var inputs = form.querySelectorAll('input[required], select[required], textarea[required]');
            var valid = true;
            
            inputs.forEach(function(input) {
                if (!input.value.trim()) {
                    input.style.borderColor = '#dc3545';
                    valid = false;
                } else {
                    input.style.borderColor = '#ddd';
                }
            });
            
            return valid;
        }
        
        // Masquer les messages après 5 secondes
        setTimeout(function() {
            var messages = document.querySelectorAll('.message-box');
            messages.forEach(function(msg) {
                msg.style.opacity = '0';
                msg.style.transition = 'opacity 0.5s';
                setTimeout(function() {
                    msg.style.display = 'none';
                }, 500);
            });
        }, 5000);
    </script>
</body>
</html>