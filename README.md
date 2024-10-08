# NCSCopyMaker

PowerShell script that generates code differences in Git repositories for specified deadlines (week by week).

For now the current week is controlled by the property `backInTimeInWeeks` in the script configuration file. If you need to generate diffs for the past weeks, increase the value of this property. You can also override it by specifying the value as an argument.

The code differences will be saved in the `diffs` folder or in the directory defined in the script configuration file.

## Script configuration

This script requires a configuration JSON file to be present in the same directory as the script with the name `config.json`. The schema for this file is provided below with the description of all its properties.

```jsonc
{
  "author": "username",
  "compress": true,
  "outputDirectory": "",
  "backInTimeInWeeks": 0,
  "debug": false,
  "deadlines": [
    "23-10-2020",
    "23-09-2020",
    "24-11-2020",
    "21-12-2020"
  ],
  // Path to the folder with repositories
  "repositories": "C:\\Projects",
  // Array of repositories
  "repositories": [
    {
      "name": "Repository A",
      "location": "C:\\Projects\\Repository A"
    },
    {
      "name": "Repository B",
      "location": "C:\\Projects\\Repository B"
    }
  ]
}
```

### Configuration object

| **Property**      | **Type**       | **Description**                               |
|-------------------|----------------|-----------------------------------------------|
| author            | string         | Name of the autor assigned in Git config to `username.email`.     |
| compress          | bool           | If `true`, the folder containing diffs will be saved as zip archive. |
| outputDirectory   | string         | Path to the directory for storing code differences. If no directory is specified, the script directory will be used. |
| backInTimeInWeeks | int            | Positive number of weeks back for which you want to run the script. Default is 0 (the current week). |
| debug             | bool           | If `true`, the folder containing diffs will be called `diffs-debug`. |
| deadlines         | array          | Array of dates defining the deadlines in each month in `dd-MM-yyyy` format. Must contain a date before the current date. |
| repositories      | array / string | Array of objects defining the repositories to track or path to a folder containing the repositories. |

__NOTE:__ There are two ways to define repositories, but only one can be configured at a time.

### Repository object

| **Property**       | **Type** | **Description**                           |
|--------------------|----------|-------------------------------------------|
| name     | string   | Name of the repository (reflected in code differences).  |
| location | string   | Full path to the repository (note the double backslashes). |

## How to run

Just create the proper `config.json` configuration file in the script location and run the script in the PowerShell console:

```lang-none
./NCSCopyMaker.ps1
```

To override a property in the configuration file, provide the value as agrument:

```lang-none
./NCSCopyMaker.ps1 -backInTimeInWeeks 2
```

Currently, the overridable properties are:

* `backInTimeInWeeks`,
* `debug`.

The code differences will be saved for each month in a separate folder called MM.yyyy, e.g. `12.2020` for December 2020. In each of the folders, you will find folders for repositories defined in the configuration file and inside you will find text files with the differences for each week, e.g. `week-48.txt`.

If the `compress` property is set to `true`, the content of the folder for the monthly diffs will be compressed into a zip archive.

### Comming soon

* Excluding commits
