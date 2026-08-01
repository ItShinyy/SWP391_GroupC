(() => {
    "use strict";

    const validatePasswordInput = (passwordInput) => {
        const pattern = new RegExp(passwordInput.dataset.passwordPattern);
        const confirmationName = passwordInput.dataset.passwordConfirmation;
        const confirmationInput = confirmationName
            ? passwordInput.form?.elements.namedItem(confirmationName)
            : null;

        const validate = () => {
            const isPasswordValid = !passwordInput.value || pattern.test(passwordInput.value);
            passwordInput.setCustomValidity(isPasswordValid ? "" : passwordInput.dataset.passwordMessage);

            if (confirmationInput instanceof HTMLInputElement) {
                const matches = !confirmationInput.value || confirmationInput.value === passwordInput.value;
                confirmationInput.setCustomValidity(matches ? "" : passwordInput.dataset.passwordMismatchMessage);
            }
        };

        passwordInput.addEventListener("input", validate);
        if (confirmationInput instanceof HTMLInputElement) {
            confirmationInput.addEventListener("input", validate);
        }
        passwordInput.form?.addEventListener("submit", (event) => {
            validate();
            if (!passwordInput.form.checkValidity()) {
                event.preventDefault();
            }
        });
    };

    document.querySelectorAll("[data-password-pattern]").forEach(validatePasswordInput);
})();
