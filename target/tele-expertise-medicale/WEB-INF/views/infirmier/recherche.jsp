<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="max-w-2xl mx-auto mt-10">
    <div class="p-8 rounded-2xl bg-slate-800/40 border border-slate-700/50 backdrop-blur-md shadow-xl">
        <div class="text-center mb-8">
            <div class="w-12 h-12 rounded-xl bg-indigo-500/20 text-indigo-400 border border-indigo-500/30 flex items-center justify-center mx-auto mb-3 font-bold text-xl">
                🔍
            </div>
            <h1 class="text-2xl font-bold text-white tracking-wide">Accueil & Admission Patient</h1>
            <p class="text-sm text-slate-400 mt-1">Saisissez le N° de Sécurité Sociale pour rechercher le dossier.</p>
        </div>

        <form action="${pageContext.request.contextPath}/infirmier/rechercher-patient" method="post" class="space-y-6">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}" />
            <div>
                <label for="nss" class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                    N° Sécurité Sociale (NSS)
                </label>
                <input type="text" id="nss" name="nss" required placeholder="ex: NSS-1002003001"
                       class="w-full px-4 py-3 rounded-xl bg-slate-900/60 border border-slate-700 text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition text-sm" />
            </div>

            <button type="submit" class="w-full py-3 px-4 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold shadow-lg shadow-indigo-600/30 border border-indigo-400/30 transition text-sm flex items-center justify-center gap-2">
                <span>Vérifier le dossier</span> ➔
            </button>
        </form>
    </div>
</div>