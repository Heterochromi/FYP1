# MMU FYP Format

**Format rendered according to the handbook's specifications. MOSTLY :)**

![ShowCase gif](showcase/showcase.gif)

## Overview

This repository aims to help you replace typical word processors, such as Microsoft Word or LibreOffice Writer, with a more intuitive and powerful tool called **Quarto** for your MMU FYP interim report.

This should let you focus on the content of your paper rather than the formatting.

### What is Quarto?

[Quarto](https://quarto.org/) is an open-source scientific and technical publishing system.

It is very important to know how Quarto operates on a basic level before using it. While it uses many different technologies and can be extended to a wide range of use cases, this is what our setup uses.

Under the hood, Quarto uses these three technologies:

1. **Markdown**
   Markdown is a lightweight markup language that uses plain-text formatting syntax. It is designed to be easy to read and easy to write, even before it is "rendered" into its final form. This is what you will be using to write your paper before it turns into a PDF. You will need basic Markdown writing knowledge (it can be learned in less than 30 minutes; see the [Markdown Guide](https://www.markdownguide.org/basic-syntax/)).

> **Before reading about Typst, you need to know this:**
> A typesetting system is a piece of software that takes your raw text and automatically turns it into a professionally designed document.
>
> The gold standard for this is actually LaTeX. It is a typesetting system that has been around for decades and is widely used in academia. It is known for its high-quality output and its extensive features. However, it is also known for its steep learning curve and its complex syntax.

2. **Typst**
   Typst is a modern, markup-based typesetting system designed to be an alternative to LaTeX. It is built in Rust, making it incredibly fast, and it produces high-quality PDFs with a much lower learning curve than its predecessor LaTeX (LaTeX is also supported by Quarto). You can see our Typst format code for the interim report at `_extensions/mmu-fyp/typst-template.typ`.

3. **Pandoc**
   Pandoc is the universal document converter. It is a command-line tool that can transform files from one markup format into another (e.g., Markdown to Word, HTML to PDF, or LaTeX to Typst).

Quarto itself does not convert, render, or edit documents; it is an orchestrator for all the other three tools, making using them much easier and more intuitive.

What quarto does under the hood:
1. It takes your markdown file `.qmd` or `.md` and checks the YAML configuration at the top.
2. It takes all the variables and the typst template and combines them into a single typst file using pandoc(markdown to typst code).
3. It then uses typst to render the document into a PDF.

## Why Quarto? Why use a typesetting system instead of word processors?

Word processors are great for short documents such as letters or company reports, but they are not designed for medium to long academic papers. You will often find yourself fighting the software to get the formatting right, and it is very easy to make a simple change and break the entire document. Overall, this is very unintuitive, distracting, and time-consuming for academic writing.

Typesetting produces perfectly replicable, professional-looking documents according to whatever standard you need (in our case, the MMU handbook). It is also a must for professional academic writing and publishing.

Quarto allows you to use Markdown or even other markup languages to produce a professional document with minimal effort, and thanks to Pandoc, it can be used as a "write once, publish anywhere" tool. Different publishers have different formatting requirements; with Quarto, you can simply change a few settings and publish to their exact format instead of rewriting your entire paper to meet their needs. So, it is super helpful for researchers to get their papers accessible in as many places as possible. 

Lastly, and arguably the best feature for us as **bachelor students** who are new to academic writing, is the extremely low entry barrier to using Quarto. In the past, you had to learn LaTeX and write literal code to produce a paper. Even with the release of Typst, which made it much easier, it would still take a large chunk of your time learning it instead of writing your paper. Now, with Quarto, you can learn the basics of Markdown in under 30 minutes, and Quarto handles all the complex formatting for you.

## ⚠️ Quick Notice Before You Move On

You will likely need to occasionally check the documentation for Quarto and Markdown to properly write your paper, and you will also need to use the CLI. At this point in your degree, doing this should be an afterthought. The minimal time you spend looking up docs and commands will be significantly less than the time you would waste fighting formatting in a word processor. If you are completely uncomfortable with the CLI, Quarto might not be for you, but I strongly suggest you try it anyway because the barrier to entry is incredibly low.

* **Quarto:** [https://quarto.org/docs/guide/](https://quarto.org/docs/guide/)
* **Markdown:** [https://www.markdownguide.org/basic-syntax/](https://www.markdownguide.org/basic-syntax/)

For absolute control, you can edit the output Typst PDF directly. You will most likely not need this, but here are the Typst docs:
* **Typst:** [https://typst.app/docs/](https://typst.app/docs/)

---

## 1. Install Quarto 

[Download and install Quarto here.](https://quarto.org/docs/get-started/)
Use your operating system's installer.

*If you are on Linux, you will need to install Microsoft's Arial fonts for Typst to render the proper required font (ignore this if you are on Windows).*

**Debian based:**
```bash
sudo apt install ttf-mscorefonts-installer
```

**Fedora / RHEL / CentOS:**
```bash
sudo dnf install mscore-fonts-all
```

**Arch Linux:**
```bash
sudo pacman -S ttf-ms-fonts
```

## 2. Install Quarto's IDE Extension 

[Download the VS Code Extension here.](https://marketplace.visualstudio.com/items?itemName=quarto.quarto) or simply look up quarto in the extension tab and install it.

This will allow you to preview the document in real time and edit inside your IDE. Many IDE extensions are available, but the best supported is VS Code.
*
> **Recommendation**: after installing the extension open VS code's settings and search for "quarto render on save" and enable it so rerenders can happen on file save.

## 3. Clone Repository

```bash
git clone https://github.com/Heterochromi/FYP1.git
```

1. Open the repo directory inside your IDE, then navigate to your `paper.qmd`.
2. Click on the **Preview** button on the top right corner of the IDE (you can also use `quarto preview paper.qmd` in the terminal if you don't have an extension).
3. You should see a rendered PDF on the right side of your screen or in your browser if you used the terminal.
4. Your PDF should be inside the same directory as `paper.qmd` named `paper.pdf`.
5. **You are done! You can go ahead and start writing your paper inside `paper.qmd`.**

> **Optional recommendation:** Delete the `.git` directory so you can push to your own repository if needed.

---

[:)](https://www.youtube.com/shorts/T2lgRadzk-0?feature=share) 
https://www.youtube.com/shorts/T2lgRadzk-0?feature=share
