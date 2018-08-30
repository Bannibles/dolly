package resolve

import (
	"os"
	"path/filepath"

	"github.com/juju/errors"
)

// Directory returns absolute dir name relative to baseDir,
// or NewNotFound error.
func Directory(dir string, baseDir string, create bool) (resolved string, err error) {
	if dir == "" {
		return dir, nil
	}
	if filepath.IsAbs(dir) {
		resolved = dir
	} else {
		resolved = filepath.Join(baseDir, dir)
	}
	if _, err := os.Stat(resolved); os.IsNotExist(err) {
		if create {
			if err = os.MkdirAll(resolved, 0744); err != nil {
				return "", errors.Annotatef(err, "crerate dir: '%s'", resolved)
			}
		} else {
			return resolved, errors.NewNotFound(err, resolved)
		}
	}
	return resolved, nil
}

// File returns absolute file name relative to baseDir,
// or NewNotFound error.
func File(file string, baseDir string) (resolved string, err error) {
	if file == "" {
		return file, nil
	}
	if filepath.IsAbs(file) {
		resolved = file
	} else {
		resolved = filepath.Join(baseDir, file)
	}
	if _, err := os.Stat(resolved); os.IsNotExist(err) {
		return resolved, errors.NewNotFound(err, resolved)
	}
	return resolved, nil
}