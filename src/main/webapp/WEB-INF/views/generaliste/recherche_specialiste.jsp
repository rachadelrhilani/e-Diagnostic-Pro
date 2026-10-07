<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="max-w-5xl mx-auto space-y-6">
    <div class="border-b border-slate-800 pb-4">
        <h2 class="text-2xl font-bold text-white">Recherche de Spécialistes</h2>
        <p class="text-sm text-slate-400">Filtrer par spécialité et tarif max via Stream API</p>
    </div>

    <!-- Formulaire de recherche -->
    <form action="${pageContext.request.contextPath}/generaliste/recherche-specialiste" method="get" class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 flex flex-wrap gap-4 items-end">
        <input type="hidden" name="consultationId" value="${param.consultationId}" />
        <div class="flex-1 min-w-[200px]">
            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Spécialité</label>
            <select name="specialite" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none">
                <option value="CARDIOLOGIE">Cardiologie</option>
                <option value="DERMATOLOGIE">Dermatologie</option>
                <option value="NEUROLOGIE">Neurologie</option>
                <option value="PEDIATRIE">Pédiatrie</option>
            </select>
        </div>
        <div class="flex-1 min-w-[200px]">
            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Tarif Max (DH)</label>
            <input type="number" name="maxTarif" placeholder="ex: 400" class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none" />
        </div>
        <button type="submit" class="px-6 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm transition">
            🔍 Rechercher
        </button>
    </form>

    <!-- Liste des Spécialistes -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <c:forEach var="s" items="${specialistes}">
            <div class="p-5 rounded-2xl bg-slate-800/30 border border-slate-700/50 flex justify-between items-center">
                <div>
                    <h3 class="font-bold text-white text-lg">Dr. ${s.prenom} ${s.nom}</h3>
                    <p class="text-xs text-indigo-400 font-medium">${s.specialite}</p>
                    <p class="text-sm text-slate-300 font-mono mt-1">Tarif: ${s.tarifAvis} DH</p>
                </div>
                <a href="${pageContext.request.contextPath}/generaliste/creneaux?specialisteId=${s.id}&consultationId=${param.consultationId}" 
                   class="px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold transition">
                    Voir Créneaux ➔
                </a>
            </div>
        </c:forEach>
    </div>
</div>

<jsp:include page="../templates/footer.jsp" />