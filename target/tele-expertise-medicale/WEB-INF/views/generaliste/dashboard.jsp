<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="space-y-6">
    <div class="flex justify-between items-center border-b border-slate-800 pb-5">
        <div>
            <h2 class="text-2xl font-bold text-white tracking-wide">Tableau de Bord - Généraliste</h2>
            <p class="text-sm text-slate-400 mt-1">Gérez vos consultations et demandes de télé-expertise.</p>
        </div>
    </div>

    <!-- Alertes -->
    <c:if test="${not empty param.msg}">
        <div class="p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-sm flex items-center gap-2">
            <span>✅</span> ${param.msg}
        </div>
    </c:if>

    <!-- Section Créer une Consultation (US1) -->
    <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 backdrop-blur-md shadow-xl">
        <h3 class="text-lg font-bold text-white mb-4 flex items-center gap-2">🩺 Nouvelle Consultation (150 DH)</h3>
        <form action="${pageContext.request.contextPath}/generaliste/creer-consultation" method="post" class="space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Patient</label>
                    <select name="patientId" required class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none">
                        <option value="" disabled selected>-- Sélectionner un patient --</option>
                        <c:forEach var="p" items="${patientsEnAttente}">
                            <option value="${p.id}">${p.nom} ${p.prenom} (${p.numeroSecuriteSociale})</option>
                        </c:forEach>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Motif</label>
                    <input type="text" name="motif" required placeholder="ex: Céphalées intenses" class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Observations</label>
                    <input type="text" name="observations" placeholder="Remarques initiales..." class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none" />
                </div>
            </div>
            <button type="submit" class="px-5 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm transition shadow-lg shadow-indigo-600/30">
                Démarrer la consultation
            </button>
        </form>
    </div>
</div>

<jsp:include page="../templates/footer.jsp" />