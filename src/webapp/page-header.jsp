<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) pageTitle = "Product Manager";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %></title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background-color: #f5f7fa;
            color: #333;
            line-height: 1.6;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            overflow: hidden;
        }
        
        header {
            background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
            color: white;
            padding: 25px 30px;
        }
        
        header h1 {
            font-size: 2.5rem;
            margin-bottom: 5px;
        }
        
        header p {
            opacity: 0.9;
            font-size: 1.1rem;
        }
        
        nav {
            background-color: #f8f9fa;
            border-bottom: 1px solid #eaeaea;
            padding: 15px 30px;
        }
        
        nav a {
            color: #2575fc;
            text-decoration: none;
            margin-right: 25px;
            padding: 8px 15px;
            border-radius: 5px;
            transition: all 0.3s;
            font-weight: 500;
        }
        
        nav a:hover {
            background-color: #e3f2fd;
            text-decoration: underline;
        }
        
        .nav-home {
            color: #6a11cb;
            font-weight: bold;
        }
        
        .content {
            padding: 30px;
            min-height: 400px;
        }
        
        .message-box {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 25px;
            border-left: 5px solid;
        }
        
        .success {
            background-color: #d4edda;
            border-left-color: #28a745;
            color: #155724;
        }
        
        .info {
            background-color: #d1ecf1;
            border-left-color: #17a2b8;
            color: #0c5460;
        }
        
        .card {
            background: white;
            border-radius: 8px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08);
            border: 1px solid #eaeaea;
        }
        
        .card h3 {
            color: #2575fc;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #444;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #ddd;
            border-radius: 6px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        
        .form-control:focus {
            border-color: #6a11cb;
            outline: none;
            box-shadow: 0 0 0 3px rgba(106, 17, 203, 0.1);
        }
        
        .btn {
            display: inline-block;
            padding: 12px 25px;
            background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(106, 17, 203, 0.3);
            color: white;
            text-decoration: none;
        }
        
        .btn-secondary {
            background: #6c757d;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        th {
            background-color: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #444;
            border-bottom: 2px solid #dee2e6;
        }
        
        td {
            padding: 15px;
            border-bottom: 1px solid #eaeaea;
        }
        
        tr:hover {
            background-color: #f8f9fa;
        }
        
        .badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        
        .badge-success {
            background-color: #d4edda;
            color: #155724;
        }
        
        .badge-warning {
            background-color: #fff3cd;
            color: #856404;
        }
        
        footer {
            text-align: center;
            padding: 25px;
            color: #666;
            border-top: 1px solid #eaeaea;
            margin-top: 30px;
            font-size: 0.9rem;
        }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 25px;
            margin-top: 30px;
        }
        
        .form-type-indicator {
            display: inline-block;
            padding: 5px 15px;
            background-color: #e3f2fd;
            border-radius: 20px;
            color: #1976d2;
            font-weight: 600;
            margin-bottom: 20px;
        }
        
        @media (max-width: 768px) {
            .grid {
                grid-template-columns: 1fr;
            }
            
            nav {
                display: flex;
                flex-wrap: wrap;
                gap: 10px;
            }
            
            nav a {
                margin-right: 0;
                margin-bottom: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Product Manager</h1>
            <p>Gestionnaire de produits avec formulaires divers</p>
        </header>
        
        <nav>
            <a href="<%= request.getContextPath() %>/" class="nav-home">🏠 Accueil</a>
            <a href="<%= request.getContextPath() %>/products">📦 Produits</a>
            <a href="<%= request.getContextPath() %>/products/form-simple">📝 Formulaire simple</a>
            <a href="<%= request.getContextPath() %>/products/form-complete">🎯 Formulaire complet</a>
            <a href="<%= request.getContextPath() %>/products/list">📋 Liste produits</a>
        </nav>
        
        <div class="content">