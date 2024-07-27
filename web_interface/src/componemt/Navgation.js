import Container from "react-bootstrap/Container";
import Nav from "react-bootstrap/Nav";
import Navbar from "react-bootstrap/Navbar";
// import NavDropdown from "react-bootstrap/NavDropdown";

let Navgation = () => {
  return (
    <Navbar expand="lg" className="bg-body-tertiary">
      <Container>
        <Navbar.Brand href="/">React-Bootstrap</Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav" />
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="me-auto">
            <Nav.Link href="/"><span style={{color: 'blue'}}>Home</span></Nav.Link>
            <Nav.Link href="/noflag"><span style={{color: 'green'}}>Non-Flagged Content</span></Nav.Link>
            <Nav.Link href="/flagged"><span style={{color: 'red'}}>Flagged Content</span></Nav.Link>
          </Nav>
        </Navbar.Collapse>
      </Container>
    </Navbar>
          );
};

export default Navgation;
