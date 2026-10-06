<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr" class="h-full">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion - Télé-Expertise Médicale</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="h-full bg-slate-950 flex items-center justify-center relative overflow-hidden font-sans antialiased">

    <!-- Orbes de couleur en arrière-plan -->
    <div class="absolute -top-32 -left-32 w-96 h-96 bg-indigo-600/30 rounded-full blur-3xl pointer-events-none"></div>
    <div class="absolute -bottom-32 -right-32 w-96 h-96 bg-emerald-500/20 rounded-full blur-3xl pointer-events-none"></div>
    <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-80 h-80 bg-blue-500/20 rounded-full blur-3xl pointer-events-none"></div>

    <!-- Carte Glassmorphism -->
    <div class="w-full max-w-md p-8 rounded-2xl bg-white/10 backdrop-blur-xl border border-white/20 shadow-2xl shadow-black/50 relative z-10 m-4">
        
        <!-- En-tête -->
        <div class="text-center mb-8">
            <h2 class="text-2xl font-bold text-white tracking-wide">Espace Connexion</h2>
            <p class="text-sm text-slate-300 mt-1">Système de Télé-expertise Médicale</p>
        </div>

        <!-- Alert Message d'erreur -->
        <c:if test="${not empty error}">
            <div class="mb-6 p-3.5 rounded-xl bg-rose-500/20 border border-rose-500/30 text-rose-200 text-sm flex items-center gap-2">
                <span>⚠️</span> ${error}
            </div>
        </c:if>

        <!-- Formulaire avec URL JSTL et Token CSRF -->
        <form action="<c:url value='/auth/login'/>" method="post" class="space-y-5">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}" />

            <div>
                <label for="email" class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                    Adresse Email
                </label>
                <input type="email" id="email" name="email" required 
                       placeholder="ex: generaliste@test.ma"
                       class="w-full px-4 py-3 rounded-xl bg-slate-900/50 border border-white/10 text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-400 transition text-sm" />
            </div>

            <div>
                <label for="password" class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                    Mot de passe
                </label>
                <input type="password" id="password" name="password" required 
                       placeholder="••••••••"
                       class="w-full px-4 py-3 rounded-xl bg-slate-900/50 border border-white/10 text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-400 transition text-sm" />
            </div>

            <button type="submit" 
                    class="w-full py-3 px-4 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold shadow-lg shadow-indigo-600/30 border border-indigo-400/30 transition duration-200 mt-2">
                Se connecter
            </button>
        </form>
    </div>

</body>
</html>