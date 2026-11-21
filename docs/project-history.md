# Project history and decisions

This document records how the project started, what research was done, and which decisions were taken and why. It was first written on 2026-11-21 from the founding discussion. New decisions should be added to the decision log at the end, with a date and a reason, so that the reasoning stays with the project.

## 1. Where we started

The first idea was a free-to-play mobile game for Indian players, similar in genre to base-building strategy games, with a desi identity and in-app purchases limited to cosmetics.

The idea changed several times during the discussion. Each change is listed below with the reason for it.

| Step | Idea | Outcome | Reason |
|---|---|---|---|
| 1 | Base-builder strategy game with an Indian setting | Dropped | It needs live servers, balancing and anti-cheat, which is too large for a small team. Cosmetics alone are also a weak income source in that genre. |
| 2 | Cricket-themed strategy game | Parked | Real players, teams and leagues need licences. A fictional-squad version needs none, so the idea returned later as one of the planned stories. |
| 3 | Whatever is working in the market, judged on ease of build, visual quality, smoothness and income | Led to hybrid-casual | Hybrid-casual was the only mobile segment still growing in revenue. |
| 4 | Hindi word puzzle with a decoration layer | Dropped | The owner wanted a broader concept and doubted that a game positioned for women would find paying players. |
| 5 | Indian lifestyle tycoon where the player chooses a role | Kept in part | The role idea became the multiple-stories idea. |
| 6 | Shared online world in the style of open-world multiplayer games | Dropped for now | It is the hardest kind of game to build and run. Online features may be added in stages later. |
| 7 | Idle simulator with Indian stories, comic-strip storytelling and high-quality art made in Blender | **Chosen** | It is small to build, runs offline, suits rewarded ads, and the story layer sets it apart from existing idle games. |

## 2. What we are building

The game is an idle simulator. The player runs a business that keeps earning while they are away, and they spend the earnings on upgrades and expansion.

The agreed design points are these:

- **Multiple stories.** Each story is a different Indian business journey with its own characters, buildings and comic pages. The player chooses one story at the start.
- **The first story is permanent.** The first playthrough cannot be swapped for another story.
- **More stories as extra playthroughs.** Other stories can be unlocked as separate playthroughs, either through a purchasable bundle or, as recommended, one earned through play.
- **Storytelling through comic strips.** Story pages are still images with text, in an original illustrated style with anime influence. New pages unlock at milestones.
- **Region and language setup on first launch.** The screen is preset from the phone's region and language, appears once, and both choices can be changed later in Settings. Choosing India adds a language step.
- **Region changes presentation, not the world.** Region sets language, currency and number format, shop prices and the festival calendar. The world stays Indian for every player.
- **Fair monetisation.** Income comes from opt-in rewarded ads, cosmetics, a pass, and story bundles. Ads are never forced and nothing that is sold makes a player stronger than another.
- **Worldwide release.** The game is Indian-themed but released in English worldwide as well as in Indian languages.

### Planned stories

| Story | Journey | Status |
|---|---|---|
| Tech startup | A shared room in Bengaluru to a global company | Playable story for the MVP |
| Film studio | Phone-shot short films to blockbuster productions | Planned for launch |
| Cricket academy | A local ground to a national-level academy, with fictional players | Planned for launch |
| Fashion label | A family handloom workshop to an international brand | Later |
| Food brand | A family recipe to a restaurant chain | Later |
| Space startup | A garage rocket project to satellite launches | Later |
| Wedding planner | Small-town events to destination weddings | Later |

A chai stall as the only story was rejected because, on its own, it leans on a stereotype of India.

## 3. Research findings

The figures below come from web search summaries of industry reports gathered on 2026-11-21. The primary reports were not opened, and several sources are vendor blogs, so the numbers should be treated as approximate.

### The Indian market

- Combined in-app and advertising revenue was about $1.1 billion in 2025, with a forecast of $1.5 billion for 2026 and $2.4 billion by 2029.
- India leads Asia on downloads but ranks sixth in the region on in-app spending.
- Two shooters, Free Fire MAX and BGMI, take about 43% of in-app spending.
- Puzzle revenue grew about 78% year on year in the first quarter of 2026.
- Ludo King remains the most-downloaded game and earns mainly from advertising.
- Hybrid-casual in-app revenue grew about 20% in 2025 to $4.2 billion worldwide, while overall mobile game spending fell 2% in the first half of 2026.
- The 2025 online gaming law bans real-money games. The former real-money companies are moving into free card and board games, so that space was judged too crowded.

### Gaps that were identified

| Rank | Gap | Notes |
|---|---|---|
| 1 | Regional-language word puzzles | The largest Hindi word game found had about 700,000 installs. |
| 2 | Indian-life tycoon or simulation | Simulation is a top download genre. Existing Indian idle games are small hobby projects. |
| 3 | Gamified general-knowledge quiz for exam aspirants | Existing apps are small, but daily content upkeep is needed. |
| 4 | Family party games on one phone | This was a hypothesis with no supporting data. |
| 5 | Mythology and folklore games | Interest is strong, but funded studios are entering and religious sensitivity is a risk. |
| 6 | Kids' learning games in Indian languages | Advertising to children is tightly regulated. |
| 7 | Culturally Indian strategy game | It has the highest ceiling but is beyond a small team. |
| 8 | Free card and board games after the real-money ban | Avoid. |

Three findings apply to every gap:

- Acquiring players in India is cheap, but keeping them is hard. One report found that 75% of games fail to keep 3% of players after 30 days.
- 77% of users in South India pay for interactive media, against 51% in the North.
- Surveys put women at 40–45% of Indian gamers, but no data was found on how much they spend.

### What players say

Reddit could not be searched because it blocks the search tool. The points below come from app-store review analyses, surveys and commentary.

- In one survey, 38% of Indian gamers said they would quit a game if ads became excessive.
- The top complaints about Ludo King are dice that feel rigged and intrusive ads.
- Players accept paying for cosmetics but resent paying for power.
- Players respond to worlds that feel Indian, to content in their own language, and to games that work offline.
- Commentators say many Indian-themed games are Western templates with a shallow Indian layer.

### How idle games earn

- Rewarded ads provide most of the income. Sources put ads at 60–90% of idle game revenue, although one market report gives purchases the larger share.
- Only 1–3% of daily players ever pay.
- The strongest ad placement is the offer to double offline earnings when the player returns. Timed income boosts and covering a cash shortfall also work.
- Idle games published worldwide earn about $0.05–$0.25 per daily player.
- Benchmarks for idle games are 40% or more of players returning on day 1 and about 6% still playing on day 30.

### Income estimate

These figures are estimates made during the discussion. They assume 3–6 rewarded ads watched per player per day.

| | India | Global benchmark |
|---|---|---|
| Rewarded ad rate per 1,000 views | $1.50–$4 | $15–$40 in the US and similar markets |
| Income per daily player | about $0.005–$0.025 | $0.05–$0.25 |
| Monthly income at 10,000 daily players | about $1,350–$7,200 | about $15,000–$75,000 |
| Monthly income at 100,000 daily players | about $13,500–$72,000 | not estimated |

An Indian player earns roughly a tenth of what a player in the US or Europe does. This is the reason for the worldwide release.

### Competition

Chai and dhaba idle games already exist, including Chaiwala Tycoon, Chai Tapri Tycoon and Idle Indian Restaurant Tycoon. They are mostly small projects with basic art. No Indian idle game was found with several stories, a storyline, or high visual quality.

## 4. Technology decisions

| Layer | Choice | Reason |
|---|---|---|
| Engine | Flutter | It was already installed, gives one codebase for Android and iOS, and runs well on low-end phones. The Flame game engine can be added when animated scenes are needed. |
| Language | Dart | It comes with Flutter. |
| Save data | On the device | The game works offline and needs no servers. |
| Backend | None for the MVP | Analytics, crash reports and cloud save can be added later. |
| Ads and purchases | None for the MVP | Rewarded ads and store purchases come after the core loop is proven. |
| Art | Blender | Models are rendered from a fixed angled camera into 2D image sequences. This gives a 3D look while the phone only draws flat images. |

Unity was considered and set aside because it is heavier, was not installed, and relies on a visual editor. It remains the fallback if the game ever needs full 3D or a live shared world.

The visual target is the level of polish seen in top strategy games. The limiting factor is artist time, so the plan is a small number of assets done very well.

## 5. MVP scope

The MVP is a build that can be checked on a phone simulator. It contains:

- a first-launch screen for region and language, preset from the phone, with English and Hindi;
- a story selection screen showing three stories, with the tech startup playable and two marked as coming soon;
- an opening comic and one more comic page unlocked at the first milestone, using placeholder art;
- the tech startup idle loop, with earning, upgrades, automation and offline earnings;
- Indian and international number and currency formatting;
- progress saved on the device.

The MVP has no ads, purchases, accounts or online features.

## 6. Open questions

- Whether a second story can be earned through play, or only bought.
- Which Indian languages follow Hindi, and whether Tamil or Telugu should come early given higher spending in the South.
- The art style for characters and comic pages.
- When to measure day 1 and day 7 retention with real players.
- Whether and when to add online features such as leaderboards and trading.

## 7. Decision log

| Date | Decision | Reason |
|---|---|---|
| 2026-11-21 | The game is free to play, with cosmetic purchases and no pay-to-win. | This was the founding requirement. |
| 2026-11-21 | Do not use real cricket players, teams or leagues. | They require licences. |
| 2026-11-21 | Avoid real-money mechanics of any kind. | The 2025 online gaming law bans them. |
| 2026-11-21 | Build an idle simulator. | It is small to build, offline, and fits rewarded ads. |
| 2026-11-21 | Use Flutter, with art produced in Blender. | See section 4. |
| 2026-11-21 | Add a storyline told through comic strips. | It gives the game personality that plain idle games lack. |
| 2026-11-21 | Offer multiple stories; the first choice is permanent and others are extra playthroughs. | It avoids a single stereotyped setting and gives a fair thing to sell. |
| 2026-11-21 | Region changes language, currency, prices and festivals, not the game world. | Separate worlds per region would multiply the art and writing work. |
| 2026-11-21 | Release worldwide in English as well as in Indian languages. | Players outside India earn about ten times more from ads. |
| 2026-11-21 | The tech startup is the playable story in the MVP. | It was chosen by the owner. |

## 8. Sources

- [Sensor Tower: India mobile market Q1 2026](https://sensortower.com/blog/india-mobile-market-q1-2026)
- [Sensor Tower: India mobile game insights 2025](https://sensortower.com/blog/india-mobile-game-insights-2025)
- [PocketGamer.biz: India's mobile games market set to reach $2.4bn by 2029](https://www.pocketgamer.biz/indias-mobile-games-market-set-to-reach-24bn-by-2029/)
- [Indian Television: India's mobile gaming market rebounds in Q2](https://indiantelevision.com/iworld/indias-mobile-gaming-market-rebounds-as-downloads-hit-2-billion-in-q2/)
- [Indian Television: India's gaming edge is cheap installs, but retention lags](https://indiantelevision.com/iworld/indias-gaming-edge-is-cheap-installs-but-player-retention-lags-report/)
- [Mobile Marketing Reads: India app revenue up 33% in Q1 2026](https://mobilemarketingreads.com/?p=50647)
- [Naavik: Ludo King takes over the Indian mobile games market](https://naavik.co/digest/ludo-king-takes-over-the-indian-mobile-games-market/)
- [Deconstructor of Fun: State of Mobile 2026](https://www.deconstructoroffun.com/blog/2026/2/2/state-of-mobile-2026)
- [PocketGamer.biz: Mobile gaming IAP dipped 2% in H1 2026](https://www.pocketgamer.biz/mobile-gaming-iap-dipped-2-as-ad-spend-climbed-in-h1-2026/)
- [Outlook Respawn: GDAI report maps funding gaps](https://respawn.outlookindia.com/gaming/gaming-news/gdai-report-maps-funding-gaps-in-indias-gaming-industry)
- [YourStory: Bharat is powering the gaming boom in India](https://yourstory.com/2025/10/bharat-tier-ii-users-powering-gaming-boom-india-report)
- [Storyboard18: Women make up 45 percent of India's gamers](https://www.storyboard18.com/gaming-news/women-make-up-45-percent-of-indias-gamers-mostly-18-30-and-beyond-metros-lumikai-83700.htm)
- [MediaBrief: Lumikai interactive media report 2025](https://mediabrief.com/lumikai-interactive-media-report-2025/)
- [Storyboard18: 75% of Indian gamers spend on in-app purchases](https://www.storyboard18.com/gaming-news/75-of-indian-gamers-spend-on-in-app-purchases-reveals-lightbox-report-81507.htm)
- [Forbes India: How online gaming companies are pivoting after the ban](https://www.forbesindia.com/article/news/how-online-gaming-companies-are-pivoting-after-the-ban/2990594/1)
- [AppsFlyer: Gaming app market benchmarks for Q3 2026](https://www.appsflyer.com/?p=549948)
- [Marlvel: Ludo King review analysis](https://marlvel.ai/apps/com-gametion-ludo/reviews)
- [Game-Ace: Idle game development](https://game-ace.com/blog/idle-game-development/)
- [IGVend: How indie games make money](https://igvend.com/en/blog/mobile-game-monetization-how-mobile-games-make-money)
- [Moonetix: How to monetize an idle or clicker game in 2026](https://moonetix.com/academy/monetization/monetize-idle-clicker-game)
- [Playio: Mobile game eCPM benchmarks 2026](https://blog.playio.co/mobile-game-ecpm-benchmarks-2026)
- [MAF: Mobile game retention benchmarks](https://maf.ad/en/blog/mobile-game-retention-benchmarks/)
- [CrazyGames: Monetizing clicker games](https://docs.crazygames.com/resources/monetizing-clicker/)
- [GameAnalytics: Eight lessons from Kolibri Games](https://www.gameanalytics.com/blog/making-a-hit-idle-game-eight-lessons-from-kolibri-games)
- [PocketGamer.biz: How h8games reinvented itself](https://www.pocketgamer.biz/from-helix-jump-to-little-farm-story-how-h8games-reinvented-itself)
- [Adobe Substance 3D: Supercell Helsinki on stylized content](https://www.adobe.com/products/substance3d/magazine/supercell-helsinki-creating-stylized-content-for-clash-of-clans-and-clash-royale.html)
- [Google Play: Chaiwala Tycoon](https://play.google.com/store/apps/details?id=com.DTGames.ChaiwalaTycoon)
- [Google Play: Chai Tapri Tycoon](https://play.google.com/store/apps/details?id=com.chaitapri.tycoon&hl=en)
