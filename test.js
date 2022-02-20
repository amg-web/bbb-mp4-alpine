const puppeteer = require('puppeteer');
const child_process = require('child_process');
// const XMLHttpRequest = require('xhr2'); //uncomment this if you want to show notes instead of chat
const Xvfb = require('xvfb');

options.executablePath = "/usr/bin/chromium-browser"

// Generate randome display port number to avoide xvfb failure
var disp_num = Math.floor(Math.random() * 100 + 99);
var xvfb = new Xvfb({
    displayNum: disp_num,
    silent: true,
    xvfb_args: ["-screen", "0", "1280x800x24", "-ac", "-nolisten", "tcp", "-dpi", "96", "+extension", "RANDR"]
});

xvfb.startSync()

async function ssr(url) {
  // set duration to 0 
  var duration = 0
  

  const browser = await puppeteer.launch({headless: true, 
                  args: [
                        '--disable-infobars',
                        '--no-sandbox',
                        '--disable-dev-shm-usage',
                        '--start-fullscreen',
 //                       '--app=url',
                        `--window-size=1280,800`,
                        ],

});
  const page = await browser.newPage();
  await page.goto(url, {waitUntil: 'networkidle0'});
  const html = await page.content(); // serialized HTML of page DOM.

// Get recording duration
  const recDuration = await page.evaluate(() => {
    return document.getElementById("vjs_video_3_html5_api").duration
        });
    duration = recDuration
    console.log("Record duration: ", duration)

    await page.waitForSelector('button[class=vjs-big-play-button]');
    await page.$eval('.bottom-content', element => element.style.display = "none");
    await page.$eval('.fullscreen-button', element => element.style.opacity = "0");
    await page.$eval('.right', element => element.style.opacity = "0");
    await page.$eval('.vjs-control-bar', element => element.style.opacity = "0");
    await page.click('button[class=vjs-big-play-button]', { waitUntil: 'domcontentloaded' });

    //  Start capturing screen with ffmpeg
    const ls = child_process.spawn('sh', ['ffmpeg-cmd.sh', ' ',
        `${duration}`, ' ',
        `${exportname}`, ' ',
        `${disp_num}`
    ], {
        shell: true
    });


    ls.stdout.on('data', (data) => {
        console.log(`stdout: ${data}`);
    });

    ls.stderr.on('data', (data) => {
        console.error(`stderr: ${data}`);
    });

    ls.on('close', (code) => {
        console.log(`child process exited with code ${code}`);
    });



  await browser.close();
  xvfb.stopSync()
  return html;
}

