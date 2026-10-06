<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="space-y-6">
    <!-- En-tête de section -->
    <div class="border-b border-slate-800 pb-5">
        <h2 class="text-2xl font-bold text-white tracking-wide">Espace Médecin Généraliste</h2>
        <p class="text-sm text-slate-400 mt-1">Gestion des consultations, diagnostics et télé-expertises.</p>
    </div>

    <!-- Alert de message -->
    <c:if test="${not empty param.msg}">
        <div class="p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-sm flex items-center gap-2">
            <span>✅</span> ${param.msg}
        </div>
    </c:if>

    <!-- Cartes d'action rapide -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Carte 1: Démarrer Consultation -->
        <div class="p-6 rounded-2xl bg-slate-800/50 backdrop-blur-md border border-slate-700/50 shadow-xl space-y-4">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-indigo-500/20 text-indigo-400 flex items-center justify-center font-bold text-lg border border-indigo-500/30">
                    🩺
                </div>
                <div>
                    <h3 class="text-lg font-bold text-white">Nouvelle Consultation</h3>
                    <p class="text-xs text-slate-400">Coût fixe: 150 DH</p>
                </div>
            </div>
            <p class="text-sm text-slate-300">Sélectionner un patient dans la file d'attente pour lancer son examen clinique et l'analyse de ses symptômes.</p>
            <a href="${pageContext.request.contextPath}/infirmier/dashboard" 
               class="inline-block w-full text-center py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm transition shadow-lg shadow-indigo-600/20 border border-indigo-400/30">
                Choisir un patient
            </a>
        </div>

        <!-- Carte 2: Rechercher Spécialiste -->
        <div class="p-6 rounded-2xl bg-slate-800/50 backdrop-blur-md border border-slate-700/50 shadow-xl space-y-4">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-blue-500/20 text-blue-400 flex items-center justify-center font-bold text-lg border border-blue-500/30">
                    🔍
                </div>
                <div>
                    <h3 class="text-lg font-bold text-white">Demande de Télé-expertise</h3>
                    <p class="text-xs text-slate-400">Cardiologue, Dermatologue, etc.</p>
                </div>
            </div>
            <p class="text-sm text-slate-300">Rechercher et filtrer les avis spécialistes par tarif et sélectionner un créneau de réservation.</p>
            <a href="${pageContext.request.contextPath}/generaliste/recherche-specialiste" 
               class="inline-block w-full text-center py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-semibold text-sm transition shadow-lg shadow-blue-600/20 border border-blue-400/30">
                Consulter l'annuaire spécialistes
            </a>
        </div>
    </div>
</div>

<jsp:include page="../templates/footer.jsp" />