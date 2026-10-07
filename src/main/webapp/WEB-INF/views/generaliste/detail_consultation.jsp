<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="max-w-4xl mx-auto space-y-6">
    <div class="flex justify-between items-center border-b border-slate-800 pb-4">
        <h2 class="text-2xl font-bold text-white">Détails de la Consultation</h2>
        <!-- US4: Affichage du Coût Total -->
        <div class="px-4 py-2 rounded-xl bg-emerald-500/20 border border-emerald-500/30 text-emerald-300 font-bold text-lg">
            Coût Total : ${coutTotal} DH
        </div>
    </div>

    <!-- Formulaire d'ajout d'acte médical -->
    <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50">
        <h3 class="text-sm font-bold text-white uppercase tracking-wider mb-4">➕ Ajouter un Acte Technique Médical</h3>
        <form action="${pageContext.request.contextPath}/generaliste/ajouter-acte" method="post" class="flex gap-4">
            <input type="hidden" name="consultationId" value="${param.id}" />
            <input type="text" name="nomActe" placeholder="ex: ECG, Glycémie" required class="flex-1 px-4 py-2 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none" />
            <input type="number" step="0.1" name="tarifActe" placeholder="Tarif (DH)" required class="w-32 px-4 py-2 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none" />
            <button type="submit" class="px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-semibold text-xs transition">
                Ajouter
            </button>
        </form>
    </div>

    <!-- Action Clôture Directe -->
    <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 space-y-4">
        <h3 class="text-sm font-bold text-white uppercase tracking-wider">🏁 Clôturer la Consultation Directe</h3>
        <form action="${pageContext.request.contextPath}/generaliste/cloturer-directe" method="post" class="space-y-4">
            <input type="hidden" name="consultationId" value="${param.id}" />
            <div>
                <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Diagnostic</label>
                <input type="text" name="diagnostic" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none" />
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Traitement Prescrit</label>
                <textarea name="traitement" rows="3" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none"></textarea>
            </div>
            <div class="flex justify-between items-center pt-2">
                <a href="${pageContext.request.contextPath}/generaliste/recherche-specialiste?consultationId=${param.id}" class="px-4 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-semibold transition">
                    Demander Avis Spécialiste ➔
                </a>
                <button type="submit" class="px-6 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-500 text-white font-semibold text-sm transition">
                    Clôturer la Consultation
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../templates/footer.jsp" />