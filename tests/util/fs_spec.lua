require("util.filesystem")

describe("FS utils", function()
  describe("removes duplicate separators", function()
    local remove_duplicate_separators = FS.remove_dup_separators

    it("should remove duplicate forward slashes", function()
      local input = "/home//user///documents////file.txt"
      local expected = "/home/user/documents/file.txt"
      assert.are.equal(expected, remove_duplicate_separators(input))
      local input2 = "//home/user//file.txt"
      local res = "/home/user/file.txt"
      assert.are.equal(res, remove_duplicate_separators(input2))
    end)

    it("should remove duplicate backslashes", function()
      local input = "C:\\\\Users\\\\John\\\\\\Documents\\\\\\file.txt"
      local expected = "C:\\Users\\John\\Documents\\file.txt"
      assert.are.equal(expected, remove_duplicate_separators(input))
    end)

    it("should handle mixed forward slashes and backslashes", function()
      local input = "C:/Users\\\\John//Documents\\\\file.txt"
      local expected = "C:/Users\\John/Documents\\file.txt"
      assert.are.equal(expected, remove_duplicate_separators(input))
    end)

    it("should not modify paths without duplicate separators", function()
      local input = "/home/user/documents/file.txt"
      assert.are.equal(input, remove_duplicate_separators(input))
    end)

    it("should handle paths with only separators", function()
      local input = "//////"
      local expected = "/"
      assert.are.equal(expected, remove_duplicate_separators(input))
    end)

    it("should return an empty string for empty input", function()
      assert.are.equal("", remove_duplicate_separators(""))
    end)
  end)
end)
