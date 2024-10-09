
const linkUrls = ["https://rstudio.github.io/chromote/","https://CRAN.R-project.org/package=Lahman","https://github.com/friendly/Guerry","https://friendly.github.io/HistData/","https://github.com/friendly/nestedLogit","https://friendly.github.io/vcdExtra/","https://github.com/hturner/gnm",null,null,"https://github.com/friendly/twoway","https://github.com/friendly/gellipsoid","https://github.com/dmurdoch/rgl","https://github.com/friendly/matlib","https://github.com/friendly/VisCollin","https://friendly.github.io/genridge/","https://github.com/friendly/mvinfluence","https://r-forge.r-project.org/projects/car/","https://r-forge.r-project.org/projects/car/","https://github.com/friendly/candisc/","http://friendly.github.io/heplots/","https://broom.tidymodels.org/"];
const darkMode = false;

document.addEventListener("DOMContentLoaded", function() {
  const container = document.getElementById("imageContainer");

  // Set color scheme based on dark mode
  if (darkMode) {
    document.documentElement.style.setProperty("--bg-color", "#1a1a1a");
    document.documentElement.style.setProperty("--text-color", "#ffffff");
    document.documentElement.style.setProperty("--tile-bg", "#2a2a2a");
    document.documentElement.style.setProperty("--attribution-bg", "rgba(255, 255, 255, 0.1)");
    document.documentElement.style.setProperty("--link-color", "#66b3ff");
  } else {
    document.documentElement.style.setProperty("--bg-color", "#ffffff");
    document.documentElement.style.setProperty("--text-color", "#000000");
    document.documentElement.style.setProperty("--tile-bg", "#f0f0f0");
    document.documentElement.style.setProperty("--attribution-bg", "rgba(0, 0, 0, 0.1)");
    document.documentElement.style.setProperty("--link-color", "#0066cc");
  }

  imagePaths.forEach((path, index) => {
    const div = document.createElement("div");
    const img = document.createElement("img");

    img.src = path;
    img.alt = "Hexagon Image " + (index + 1);

    if (linkUrls[index] && linkUrls[index] !== "NA") {
      const a = document.createElement("a");
      a.href = linkUrls[index];
      a.target = "_blank";
      a.appendChild(img);
      div.appendChild(a);
    } else {
      div.appendChild(img);
    }

    container.appendChild(div);
  });
});
