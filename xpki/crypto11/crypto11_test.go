package crypto11

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/juju/errors"
)

// p11lib specifies PKCS11 Context for the loaded HSM module
var p11lib *PKCS11Lib

const projFolder = "../.."

func findConfigFilePath(baseName string) (string, error) {
	wd, err := os.Getwd() // package dir
	if err != nil {
		return "", errors.Annotate(err, "unable to determine current directory")
	}

	projRoot, err := filepath.Abs(filepath.Join(wd, projFolder))
	if err != nil {
		return "", errors.Annotate(err, "failed to determine project directory")
	}

	return filepath.Join(projRoot, baseName), nil
}

func loadConfigAndInitP11() error {
	f, err := findConfigFilePath("./etc/dev/softhsm_unittest.json")
	if err != nil {
		return errors.Annotate(err, "unable to find: softhsm_unittest.json")
	}

	p11lib, err = ConfigureFromFile(f)
	if err != nil {
		return errors.Annotatef(err, "failed to load HSM config in dir: %s", f)
	}
	return nil
}

func TestMain(m *testing.M) {
	if err := loadConfigAndInitP11(); err != nil {
		panic(errors.Trace(err))
	}
	defer p11lib.Close()
	retCode := m.Run()
	os.Exit(retCode)
}
