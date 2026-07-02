const navToggle = document.querySelector("[data-nav-toggle]");
const nav = document.querySelector("[data-nav]");
const header = document.querySelector("[data-header]");
const storyTabs = document.querySelectorAll("[data-story]");
const storyPreview = document.querySelector("[data-story-preview]");
const storyTitle = document.querySelector("[data-story-title]");
const storyText = document.querySelector("[data-story-text]");
const webInstallButton = document.querySelector("[data-install-web]");
const copyButtons = document.querySelectorAll("[data-copy-command]");

const stories = [
  {
    name: "Pip's Blue Gear",
    text: "A clever little robot follows clues through the Whispering Woods to find a shiny blue gear.",
    color: "#4FC3F7",
  },
  {
    name: "Sparky's Cosmic Voyage",
    text: "A rocket robot visits Neon-X, meets Twinkle, and dances under cosmic stardust.",
    color: "#8B5CF6",
  },
  {
    name: "Coral's Deep Sea Discovery",
    text: "A submarine bot explores turquoise water, bubbly pearls, and a rainbow treasure.",
    color: "#40E0D0",
  },
  {
    name: "Rusty's Dino Dig",
    text: "A yellow explorer bot digs in Sunny Valley and discovers a fossilized dinosaur footprint.",
    color: "#81C784",
  },
  {
    name: "Bella's Bubble Kingdom",
    text: "A magic robot in a pink bubble castle helps a bluebird with a giant bouncy bubble.",
    color: "#F06292",
  },
];

let deferredInstallPrompt = null;

if (navToggle && nav) {
  navToggle.addEventListener("click", () => {
    const isOpen = nav.classList.toggle("is-open");
    navToggle.setAttribute("aria-expanded", String(isOpen));
  });

  nav.addEventListener("click", (event) => {
    if (event.target instanceof HTMLAnchorElement) {
      nav.classList.remove("is-open");
      navToggle.setAttribute("aria-expanded", "false");
    }
  });
}

window.addEventListener("scroll", () => {
  if (!header) return;
  header.classList.toggle("is-scrolled", window.scrollY > 10);
}, { passive: true });

storyTabs.forEach((tab) => {
  tab.addEventListener("click", () => {
    const storyIndex = Number(tab.dataset.story || 0);
    const story = stories[storyIndex];
    if (!story || !storyPreview || !storyTitle || !storyText) return;

    storyTabs.forEach((item) => item.classList.remove("is-active"));
    tab.classList.add("is-active");
    storyTitle.textContent = story.name;
    storyText.textContent = story.text;
    storyPreview.style.borderColor = `${story.color}80`;
    storyPreview.style.background = `linear-gradient(135deg, ${story.color}24, rgba(255,255,255,0.52))`;
  });
});

window.addEventListener("beforeinstallprompt", (event) => {
  event.preventDefault();
  deferredInstallPrompt = event;
  if (webInstallButton) {
    webInstallButton.textContent = "Install now";
  }
});

if (webInstallButton) {
  webInstallButton.addEventListener("click", async () => {
    if (deferredInstallPrompt) {
      deferredInstallPrompt.prompt();
      await deferredInstallPrompt.userChoice;
      deferredInstallPrompt = null;
      webInstallButton.textContent = "Install web app";
      return;
    }

    webInstallButton.textContent = "Use browser install menu";
    setTimeout(() => {
      webInstallButton.textContent = "Install web app";
    }, 2400);
  });
}

copyButtons.forEach((button) => {
  button.addEventListener("click", async () => {
    const command = button.dataset.copyCommand;
    if (!command) return;

    try {
      await navigator.clipboard.writeText(command);
      button.textContent = "Command copied";
    } catch {
      button.textContent = command;
    }

    setTimeout(() => {
      button.textContent = "Copy APK build command";
    }, 2400);
  });
});
