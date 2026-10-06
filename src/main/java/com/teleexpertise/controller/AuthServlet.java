package com.teleexpertise.controller;

import com.teleexpertise.dao.UtilisateurDao;
import com.teleexpertise.model.Role;
import com.teleexpertise.model.Utilisateur;
import com.teleexpertise.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Optional;

@WebServlet("/auth/*")
public class AuthServlet extends HttpServlet {

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        UtilisateurDao utilisateurDao = new UtilisateurDao();
        this.authService = new AuthService(utilisateurDao);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();

        if (path != null && path.contains("logout")) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        System.out.println("=== DEBUT LOGIN ===");
        System.out.println("Email saisi : " + email);

        Optional<Utilisateur> userOpt = authService.login(email, password);

        if (userOpt.isPresent()) {
            Utilisateur user = userOpt.get();
            System.out.println("Connexion réussie pour : " + user.getNom() + " (" + user.getRole() + ")");

            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);

            Role role = user.getRole();
            if (role == Role.INFIRMIER) {
                resp.sendRedirect(req.getContextPath() + "/infirmier/dashboard");
            } else if (role == Role.GENERALISTE) {
                resp.sendRedirect(req.getContextPath() + "/generaliste/dashboard");
            } else if (role == Role.SPECIALISTE) {
                resp.sendRedirect(req.getContextPath() + "/specialiste/dashboard");
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/login");
            }
        } else {
            System.out.println("Echec d'authentification pour : " + email);
            req.setAttribute("error", "Email ou mot de passe incorrect.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        }
    }
}