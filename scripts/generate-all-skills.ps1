$Skills = @{
    "core" = @(
        "architect",
        "principal-engineer",
        "debugger",
        "bug-hunter",
        "code-review",
        "refactor",
        "performance",
        "security",
        "testing",
        "documentation"
    )

    "ai" = @(
        "ai-engineer",
        "prompt-engineer",
        "agent-builder",
        "mcp-builder",
        "rag-engineer",
        "embedding-engineer",
        "llm-engineer",
        "tool-builder",
        "workflow-designer",
        "evaluation-engineer"
    )

    "languages" = @(
        "python-expert",
        "javascript-expert",
        "typescript-expert",
        "node-expert",
        "react-expert",
        "nextjs-expert",
        "rust-expert",
        "go-expert",
        "java-expert",
        "cpp-expert"
    )

    "backend" = @(
        "api-design",
        "database-design",
        "postgres",
        "sqlite",
        "redis",
        "mongodb",
        "graphql",
        "fastapi",
        "express",
        "django"
    )

    "devops" = @(
        "docker",
        "kubernetes",
        "terraform",
        "github-actions",
        "ci-cd",
        "linux",
        "networking",
        "cloud"
    )

    "security" = @(
        "security-audit",
        "penetration-testing",
        "secure-coding",
        "authentication",
        "cryptography"
    )

    "advanced" = @(
        "system-design",
        "distributed-systems",
        "algorithm-expert",
        "optimization",
        "reverse-engineering",
        "compiler-design",
        "operating-systems"
    )
}


foreach ($Category in $Skills.Keys) {

    foreach ($Skill in $Skills[$Category]) {

        $Folder = "skills\$Category\$Skill"

        New-Item -ItemType Directory -Path $Folder -Force | Out-Null

        $Content = @"
---
name: $Skill
description: Expert-level $Skill development workflow.
---

# $Skill

## Role

You are a specialized expert in $Skill.

## Responsibilities

- Analyze problems carefully.
- Provide professional solutions.
- Explain technical decisions.
- Follow industry best practices.
- Consider security, performance, and maintainability.

## Rules

- Do not invent information.
- Do not ignore edge cases.
- Prefer scalable solutions.
- Write clean, production-quality work.

"@

        Set-Content "$Folder\SKILL.md" $Content
    }
}

Write-Host "GOD-OPENCODE skills generated successfully."