import { useState, useEffect } from "react";

import Container from "react-bootstrap/Container";
import Nav from "react-bootstrap/Nav";
import Navbar from "react-bootstrap/Navbar";
import NavDropdown from "react-bootstrap/NavDropdown";

let Navgation = () => {
  const localThemeKey = "theme";

  const [theme, setTheme] = useState(
    localStorage.getItem(localThemeKey) === "light" ? "light" : "dark"
  );

  useEffect(() => {
    let data = localStorage.getItem(localThemeKey);
    data === "light" ? setTheme("light") : setTheme("dark");
  }, []);

  useEffect(() => {
    localStorage.setItem(localThemeKey, theme);
    document.body.setAttribute("data-bs-theme", theme);
  }, [theme]);

  const toggleTheme = () => {
    theme === "light" ? setTheme("dark") : setTheme("light");
  };

  return (
    <Navbar expand="lg" className="bg-body-tertiary">
      <Container>
        <Navbar.Brand href="/">AI Content Filter</Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav" />
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="me-auto">
            <Nav.Link href="/">
              <span className="text-primary">Home</span>
            </Nav.Link>
            <Nav.Link href="/not_flagged">
              <span className="text-success">Non-Flagged Content</span>
            </Nav.Link>
            <Nav.Link href="/flagged">
              <span className="text-danger">Flagged Content</span>
            </Nav.Link>
            <NavDropdown title="Controls" id="basic-nav-dropdown">
              <NavDropdown.Item href="/sns_controller">
                Alert Emails
              </NavDropdown.Item>
              <NavDropdown.Item href="/flagger_control">
                Content Flagger Paramaters
              </NavDropdown.Item>
              <NavDropdown.Item onClick={toggleTheme}>
                {theme === "light" ? "Dark Mode" : "Light Mode"}
              </NavDropdown.Item>
            </NavDropdown>
          </Nav>
        </Navbar.Collapse>
      </Container>
    </Navbar>
  );
};

export default Navgation;
