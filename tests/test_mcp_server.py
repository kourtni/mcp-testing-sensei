"""Unit tests for the mcp_server module."""

import mcp_server


class TestVersion:
    """Tests for version constant."""

    def test_version_constant(self):
        """Test that __version__ is properly defined."""
        assert hasattr(mcp_server, '__version__')
        assert isinstance(mcp_server.__version__, str)
        assert mcp_server.__version__  # Not empty
        # Version should match semantic versioning pattern
        parts = mcp_server.__version__.split('.')
        assert len(parts) == 3
        assert all(part.isdigit() for part in parts)


class TestTestingPrinciples:
    """Tests for testing principles functions."""

    def test_testing_principles_constant(self):
        """Test that TESTING_PRINCIPLES is properly defined."""
        assert isinstance(mcp_server.TESTING_PRINCIPLES, list)
        assert len(mcp_server.TESTING_PRINCIPLES) == 5
        assert all(isinstance(principle, str) for principle in mcp_server.TESTING_PRINCIPLES)

        # Check specific principles are present
        assert any('written before implementation' in p for p in mcp_server.TESTING_PRINCIPLES)
        assert any('document the behavior' in p for p in mcp_server.TESTING_PRINCIPLES)
        assert any('single concern' in p for p in mcp_server.TESTING_PRINCIPLES)
        assert any('deterministic and isolated' in p for p in mcp_server.TESTING_PRINCIPLES)
        assert any('declarative manner' in p for p in mcp_server.TESTING_PRINCIPLES)

    def test_get_testing_principles(self):
        """Test get_testing_principles returns the correct format."""
        result = mcp_server.get_testing_principles()

        assert isinstance(result, dict)
        assert 'principles' in result
        assert result['principles'] is mcp_server.TESTING_PRINCIPLES
        assert result['principles'] == mcp_server.TESTING_PRINCIPLES
