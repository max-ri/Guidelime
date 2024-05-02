# Lib: HereBeDragons

## [2.13-release](https://github.com/Nevcairiel/HereBeDragons/tree/2.13-release) (2023-07-12)
[Full Changelog](https://github.com/Nevcairiel/HereBeDragons/compare/2.12-release...2.13-release) [Previous Releases](https://github.com/Nevcairiel/HereBeDragons/releases)

- Update TOC for 10.1.5  
- HBD-Pins-2.0: Hack around combat limitations in 10.1.5  
    SetPassThroughButtons can no longer be called in combat, but we allow  
    creating pins at any time during play. Until such a point when this is  
    fixed by Blizzard, noop out the function so that creating pins no longer  
    errors.  
    This function is called on the pin by Blizzards pin handler, which is of  
    course insecure on addon-created pins.  
- Update TOC for 10.1  
- Update TOC for 10.0.7  
