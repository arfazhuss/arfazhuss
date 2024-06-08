# #!/bin/bash

DATA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to escape LaTeX special characters
ESC_LATEX() {
    echo "$1" | sed -e 's/\\/\\\\/g' \
                    -e 's/{/\\{/g' \
                    -e 's/}/\\}/g' \
                    -e 's/\$/\\$/g' \
                    -e 's/&/\\&/g' \
                    -e 's/#/\\#/g' \
                    -e 's/_/\\_/g' \
                    -e 's/%/\\%/g' \
                    -e 's/\^/\\^/g' \
                    -e 's/\~/\\~/g'
}

# Function to create a dropdown menu
DROP_DOWN() {
    local origin="$1"
    local query="$2"
    local ADD="++++++"
    local options=$(cat "$origin" 2>/dev/null)
    local state=$(echo "$ADD\n$options" | fzf --height 10% --border --prompt "$query ")
    [[ -z "$state" || "$state" == "exit" ]] && exit
    if [ "$state" = "$ADD" ]; then
        read -p $'\e[1;33mEnter State: \e[0m' new_state
        read -n 1 -r -s -p $'Press any key to continue...\n'
        echo "$new_state" >>"$origin"
        echo "$new_state"
    else
        echo "$state"
    fi
}

# Function to get the Position
get_title() {
    local title_origin="$DATA_DIR/0 ATM/title_data.txt"
    local title_query="Enter Position:"
    echo "$(DROP_DOWN "$title_origin" "$title_query")"
}

# Function to get the Company Name
get_company_name() {
    local company_name_origin="$DATA_DIR/0 ATM/company_data/company_name.txt"
    local company_name_query="Enter Company Name:"
    echo "$(DROP_DOWN "$company_name_origin" "$company_name_query")"
}

# Function to get the Company Suffix
get_company_suffix() {
    local company_suffix_origin="$DATA_DIR/0 ATM/company_data/company_suffix.txt"
    local company_suffix_query="Enter Company Suffix:"
    echo "$(DROP_DOWN "$company_suffix_origin" "$company_suffix_query")"
}

get_state() {
    local province_origin="$DATA_DIR/0 ATM/location_data/Provinces.txt"
    local province_query="Enter Province name:"
    echo "$(DROP_DOWN "$province_origin" "$province_query")"
}

get_city() {
    local locationState="$1"
    [ -z "$locationState" ] && { echo "$province_query No province selected."; exit 1; }
    local city_origin="$DATA_DIR/0 ATM/location_data/${locationState// /_}.txt"
    local city_query="Enter City name:"
    local locationCity=$(DROP_DOWN "$city_origin" "$city_query")
    [ -z "$locationCity" ] && { echo "$city_query No city selected."; exit 1; } 
    echo "$locationCity"
}

# Function to get the Division
get_division() {
    local division_origin="$DATA_DIR/0 ATM/company_data/company_division.txt"
    local division_query="Enter Division:"
    echo "$(DROP_DOWN "$division_origin" "$division_query")"
}

# Function to get the Terms
get_terms() {
    local terms_origin="$DATA_DIR/0 ATM/term_data.txt"
    local terms_query="Enter Terms:"
    echo "$(DROP_DOWN "$terms_origin" "$terms_query")"
}

# Function to generate LaTeX file
generate_cover_latex() {
    position="$1"
    company_name="$2"
    company_suffix="$3"
    division="$4"
    locationCity="$5"
    locationState="$6"
    terms="$7"

    # Generate LaTeX file content
    cat <<-EOL > tntx.tex
        \documentclass[a4paper, 12pt]{letter}
        \usepackage{graphicx}
        \usepackage{hyperref}
        \usepackage{amsmath}
        \usepackage{lmodern}
        \usepackage{xcolor}
        \usepackage{adjustbox}
        \usepackage{fancyhdr}
        \usepackage{etoolbox}
        \usepackage[left=0.75in, right=0.75in, top=0.2in, bottom=0.5in]{geometry}

        % Define the new ruler command
        \newcommand{\CustomRuler}{\vspace{0\baselineskip}\textcolor{black}{\rule{\linewidth}{0.5pt}}\vspace{-0.5\baselineskip}}

        % Define color for hyperlinks
        \definecolor{linkblue}{HTML}{0000FF} % Blue color

        % Set up hyperref package
        \hypersetup{
            colorlinks=true,
            linkcolor=linkblue, % Color of internal links
            urlcolor=linkblue, % Color of URLs
        }

        % Redefine footer style to remove page number
        \fancypagestyle{plain}{
            \fancyhf{} % Clear header and footer
            \renewcommand{\headrulewidth}{0pt}
        }

        % Define variables
        \newcommand{\Position}{$position}
        \newcommand{\CompanyName}{$company_name}
        \newcommand{\CompanyNameSuffix}{$company_suffix}
        \newcommand{\Division}{$division}
        \newcommand{\LocationCity}{$locationCity}
        \newcommand{\LocationState}{$locationState}
        \newcommand{\Terms}{$terms}

        \begin{document}
        \pagestyle{empty}

        % Header with name and links
        \noindent
        \begin{minipage}[t]{0.5\textwidth}
            \raggedright
            \vspace{3pt}
            {\fontsize{30}{34}\selectfont Arfaz Hossain} \\\\
            \vspace{2pt}
            {\fontsize{12}{14}\selectfont Victoria, British Columbia}
        \end{minipage}%
        \begin{minipage}[t]{0.5\textwidth}
            \raggedleft
            \vspace{1pt}
            \href{https://www.github.com/arfazhxss}{\fontsize{12}{14}\selectfont www.github.com/arfazhxss} \\\\
            \href{https://www.linkedin.com/in/arfazhussain}{\fontsize{12}{14}\selectfont www.linkedin.com/in/arfazhussain} \\\\
            \href{https://arfazhxss.ca/resume.pdf}{\fontsize{12}{14}\selectfont arfazhxss.ca/resume.pdf}
        \end{minipage}

        \CustomRuler

        \vspace{10pt} \today

        \vspace{5pt}
        % Letter details
        \textbf{\CompanyName}\textbf{ \CompanyNameSuffix} \\\\
        \text{Division: \Division} \\\\
        \text{Location: \LocationCity}, \text{\LocationState} \\\\

        \vspace{-5pt}

        \text{Dear Hiring Manager,}

        \vspace{3pt}
        I am excited to apply for the {\fontsize{11}{11.5}\selectfont \bfseries \Position} Co-op Placement at {\fontsize{11}{11.5}\selectfont \bfseries \CompanyName}. I am a software engineering student at the University of Victoria in British Columbia. I am eager to learn and grow in the field of computer and software engineering, and I believe that this role will help me gain valuable work experience related to my interests and help me acquire a practical understanding in a real-world setting.

        {\fontsize{11}{11.5}\selectfont \bfseries I have a fascination for developing web and mobile applications, and I am continually learning new skills through personal projects outside school.} I have been involved in more than 13 software development projects, including developing an iOS weather application in Swift Programming Language, creating a 3D graphical simulation of a Rubik’s Cube in OpenGL and C++, and developing web development projects in React, JavaScript, and TypeScript. I have been an active member of the Engineering Students Society and UVic Students Society, where I have worked as a mentor during my second year and volunteered in multiple events while engaging in software development projects throughout my time.

        {\fontsize{11}{11.5}\selectfont \bfseries Throughout my academic endeavours, I have had the chance to learn the basic concepts of object-oriented programming, software architecture and development, testing and evolution, data structures and algorithms.} I have actively contributed to UVic Rocketry and VikeLabs as a full-stack web developer, where I have spent much of my time collaborating and developing solutions to issues while reviewing code mostly written in TypeScript and Python. My experience includes developing schemas in both MongoDB and PostgreSQL using Atlas, as well as other database tools and services such as Prisma, PlanetScale, and Mongoose. Throughout my projects, I have used automation and testing frameworks such as Selenium, Puppeteer, JUnit, Maven, and Gradle. While working in teams at UVic Rocketry, I used ticketing tools such as Jira and Kanban. I plan to specialize in visual computing and data mining, involved in projects that are closely tied to my interests. My strength lies in my ability to work independently, collaborate, adapt to new environments, and gain familiarity with new tools necessary to excel in this role.

        {\fontsize{11}{11.5}\selectfont \bfseries I am currently available for \Terms\ work term and would be open to the possibility of participating in more than two consecutive terms.} Thank you for considering my application. I look forward to the opportunity to further discuss my skills and experience with \CompanyName.

        \vspace{10pt}
        \text{Most Sincerely,}

        \vspace{-25pt}
        \begin{flushleft}
            \hspace*{-1cm}\includegraphics[width=10cm]{../../9.1 PreProcessed/signature.png}\vspace{-1cm}
        \end{flushleft}


        \vspace{-10pt}
        \ps{\textbf{Arfaz Hossain} (He/Him)\\\\
        Software Engineering Student,\\\\
        University of Victoria}

        \end{document}
EOL
}

# Escape LaTeX special characters in variables
position=$(ESC_LATEX "$(get_title)")
company_name=$(ESC_LATEX "$(get_company_name)")
company_suffix=$(ESC_LATEX "$(get_company_suffix)")
division=$(ESC_LATEX "$(get_division)")
locationState=$(ESC_LATEX "$(get_state)")
locationCity=$(ESC_LATEX "$(get_city "$locationState")")
terms=$(ESC_LATEX "$(get_terms)")

# Check if any of the variables are empty and exit if so
for var in position company_name division locationCity locationState terms; do
    [[ -z ${!var} ]] && { echo "The variable '$var' is empty. Exiting."; exit 1; }
done

filename="Hussain, Arfaz - Placement Application - ${position} - ${company_name} ${company_suffix} - ${division}"
generate_cover_latex "$position" "$company_name" "$company_suffix" "$division" "$locationCity" "$locationState" "$terms"
unset position company_name company_suffix division locationCity locationState terms 

# echo "$filename"
filename=$(echo "$filename" | sed 's/[\/\\,;]//g')
mv tntx.tex "9.2 PostProcessed/tex-outputs/" || exit
cd "9.2 PostProcessed/tex-outputs"
pdflatex tntx.tex && mv tntx.pdf "$filename.pdf"
cp "$filename.pdf" ../
cp "$filename.pdf" ../../1\ jne\ 10/
shopt -s extglob
rm -f !(*.tex)
cd ../../ || exit

echo "Cover letter generated and saved as $filename.pdf"
unset filename DATA_DIR