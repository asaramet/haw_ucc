import { platformBrowser } from '@angular/platform-browser';
import { enableProdMode } from '@angular/core';

import { AppModuleNgFactory } from "./app/app.module.ngfactory.js";

// Enable production mode unless running locally
//if (!/loclahost/.test(document.location.host)) { enableProdMode(); }

enableProdMode();
platformBrowser().bootstrapModuleFactory(AppModuleNgFactory);
