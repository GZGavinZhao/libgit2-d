/*
 * Copyright (C) the libgit2 contributors. All rights reserved.
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */
module libgit2_d.merge;


private static import libgit2_d.checkout;
private static import libgit2_d.diff;
private static import libgit2_d.index;
private static import libgit2_d.oid;
private static import libgit2_d.oidarray;
private static import libgit2_d.types;

/**
 * @file git2/merge.h
 * @brief Git merge routines
 * @defgroup git_merge Git merge routines
 * @ingroup Git
 * @{
 */
extern (C):
nothrow @nogc:
public:

/**
 * The file inputs to `git_merge_file`.  Callers should populate the
 * `git_merge_file_input` structure with descriptions of the files in
 * each side of the conflict for use in producing the merge file.
 */
struct git_merge_file_input
{
	uint version_;

	/** Pointer to the contents of the file. */
	const (char)* ptr_;

	/** Size of the contents pointed to in `ptr_`. */
	size_t size;

	/** File name of the conflicted file, or `null` to not merge the path. */
	const (char)* path;

	/** File mode of the conflicted file, or `0` to not merge the mode. */
	uint mode;
}

enum GIT_MERGE_FILE_INPUT_VERSION = 1;

pragma(inline, true)
pure nothrow @safe @nogc
.git_merge_file_input GIT_MERGE_FILE_INPUT_INIT()

	do
	{
		.git_merge_file_input OUTPUT =
		{
			version_: .GIT_MERGE_FILE_INPUT_VERSION,
		};

		return OUTPUT;
	}

/**
 * Initializes a `git_merge_file_input` with default values. Equivalent to
 * creating an instance with GIT_MERGE_FILE_INPUT_INIT.
 *
 * @param opts the `git_merge_file_input` instance to initialize.
 * @param version_ the version of the struct; you should pass
 *        `GIT_MERGE_FILE_INPUT_VERSION` here.
 * @return Zero on success; -1 on failure.
 */
//GIT_EXTERN
int git_merge_file_input_init(.git_merge_file_input* opts, uint version_);

/**
 * Flags for `git_merge` options.  A combination of these flags can be
 * passed in via the `flags` value in the `git_merge_options`.
 */
enum git_merge_flag_t
{
	/**
	 * Detect renames that occur between the common ancestor and the "ours"
	 * side or the common ancestor and the "theirs" side.  This will enable
	 * the ability to merge between a modified and renamed file.
	 */
	GIT_MERGE_FIND_RENAMES = (1 << 0),

	/**
	 * If a conflict occurs, exit immediately instead of attempting to
	 * continue resolving conflicts.  The merge operation will fail with
	 * git_error_code.GIT_EMERGECONFLICT and no index will be returned.
	 */
	GIT_MERGE_FAIL_ON_CONFLICT = (1 << 1),

	/**
	 * Do not write the REUC extension on the generated index
	 */
	GIT_MERGE_SKIP_REUC = (1 << 2),

	/**
	 * If the commits being merged have multiple merge bases, do not build
	 * a recursive merge base (by merging the multiple merge bases),
	 * instead simply use the first base.  This flag provides a similar
	 * merge base to `git-merge-resolve`.
	 */
	GIT_MERGE_NO_RECURSIVE = (1 << 3),
}

/**
 * Merge file favor options for `git_merge_options` instruct the file-level
 * merging functionality how to deal with conflicting regions of the files.
 */
enum git_merge_file_favor_t
{
	/**
	 * When a region of a file is changed in both branches, a conflict
	 * will be recorded in the index so that `git_checkout` can produce
	 * a merge file with conflict markers in the working directory.
	 * This is the default.
	 */
	GIT_MERGE_FILE_FAVOR_NORMAL = 0,

	/**
	 * When a region of a file is changed in both branches, the file
	 * created in the index will contain the "ours" side of any conflicting
	 * region.  The index will not record a conflict.
	 */
	GIT_MERGE_FILE_FAVOR_OURS = 1,

	/**
	 * When a region of a file is changed in both branches, the file
	 * created in the index will contain the "theirs" side of any conflicting
	 * region.  The index will not record a conflict.
	 */
	GIT_MERGE_FILE_FAVOR_THEIRS = 2,

	/**
	 * When a region of a file is changed in both branches, the file
	 * created in the index will contain each unique line from each side,
	 * which has the result of combining both files.  The index will not
	 * record a conflict.
	 */
	GIT_MERGE_FILE_FAVOR_UNION = 3,
}

/**
 * File merging flags
 */
enum git_merge_file_flag_t
{
	/** Defaults */
	GIT_MERGE_FILE_DEFAULT = 0,

	/** Create standard conflicted merge files */
	GIT_MERGE_FILE_STYLE_MERGE = (1 << 0),

	/** Create diff3-style files */
	GIT_MERGE_FILE_STYLE_DIFF3 = (1 << 1),

	/** Condense non-alphanumeric regions for simplified diff file */
	GIT_MERGE_FILE_SIMPLIFY_ALNUM = (1 << 2),

	/** Ignore all whitespace */
	GIT_MERGE_FILE_IGNORE_WHITESPACE = (1 << 3),

	/** Ignore changes in amount of whitespace */
	GIT_MERGE_FILE_IGNORE_WHITESPACE_CHANGE = (1 << 4),

	/** Ignore whitespace at end of line */
	GIT_MERGE_FILE_IGNORE_WHITESPACE_EOL = (1 << 5),

	/** Use the "patience diff" algorithm */
	GIT_MERGE_FILE_DIFF_PATIENCE = (1 << 6),

	/** Take extra time to find minimal diff */
	GIT_MERGE_FILE_DIFF_MINIMAL = (1 << 7),
}

enum GIT_MERGE_CONFLICT_MARKER_SIZE = 7;

/**
 * Options for merging a file
 */
struct git_merge_file_options
{
	uint version_;

	/**
	 * Label for the ancestor file side of the conflict which will be prepended
	 * to labels in diff3-format merge files.
	 */
	const (char)* ancestor_label;

	/**
	 * Label for our file side of the conflict which will be prepended
	 * to labels in merge files.
	 */
	const (char)* our_label;

	/**
	 * Label for their file side of the conflict which will be prepended
	 * to labels in merge files.
	 */
	const (char)* their_label;

	/** The file to favor in region conflicts. */
	.git_merge_file_favor_t favor;

	/** see `git_merge_file_flag_t` above */
	uint flags;

	/**
	 * The size of conflict markers (eg, "<<<<<<<").  Default is
	 * GIT_MERGE_CONFLICT_MARKER_SIZE.
	 */
	ushort marker_size;
}

enum GIT_MERGE_FILE_OPTIONS_VERSION = 1;

pragma(inline, true)
pure nothrow @safe @nogc
.git_merge_file_options GIT_MERGE_FILE_OPTIONS_INIT()

	do
	{
		.git_merge_file_options OUTPUT =
		{
			version_: .GIT_MERGE_FILE_OPTIONS_VERSION,
		};

		return OUTPUT;
	}

/**
 * Initialize git_merge_file_options structure
 *
 * Initializes a `git_merge_file_options` with default values. Equivalent to
 * creating an instance with `GIT_MERGE_FILE_OPTIONS_INIT`.
 *
 * @param opts The `git_merge_file_options` struct to initialize.
 * @param version The struct version; pass `GIT_MERGE_FILE_OPTIONS_VERSION`.
 * @return Zero on success; -1 on failure.
 */
//GIT_EXTERN
int git_merge_file_options_init(.git_merge_file_options* opts, uint version_);

/**
 * Information about file-level merging
 */
struct git_merge_file_result
{
	/**
	 * True if the output was automerged, false if the output contains
	 * conflict markers.
	 */
	uint automergeable;

	/**
	 * The path that the resultant merge file should use, or null if a
	 * filename conflict would occur.
	 */
	const (char)* path;

	/** The mode that the resultant merge file should use.  */
	uint mode;

	/** The contents of the merge. */
	const (char)* ptr_;

	/** The length of the merge contents. */
	size_t len;
}

/**
 * Merging options
 */
struct git_merge_options
{
	uint version_;

	/** See `git_merge_flag_t` above */
	uint flags;

	/**
	 * Similarity to consider a file renamed (default 50).  If
	 * `git_merge_flag_t.GIT_MERGE_FIND_RENAMES` is enabled, added files will be compared
	 * with deleted files to determine their similarity.  Files that are
	 * more similar than the rename threshold (percentage-wise) will be
	 * treated as a rename.
	 */
	uint rename_threshold;

	/**
	 * Maximum similarity sources to examine for renames (default 200).
	 * If the number of rename candidates (add / delete pairs) is greater
	 * than this value, inexact rename detection is aborted.
	 *
	 * This setting overrides the `merge.renameLimit` configuration value.
	 */
	uint target_limit;

	/** Pluggable similarity metric; pass null to use internal metric */
	libgit2_d.diff.git_diff_similarity_metric* metric;

	/**
	 * Maximum number of times to merge common ancestors to build a
	 * virtual merge base when faced with criss-cross merges.  When this
	 * limit is reached, the next ancestor will simply be used instead of
	 * attempting to merge it.  The default is unlimited.
	 */
	uint recursion_limit;

	/**
	 * Default merge driver to be used when both sides of a merge have
	 * changed.  The default is the `text` driver.
	 */
	const (char)* default_driver;

	/**
	 * Flags for handling conflicting content, to be used with the standard
	 * (`text`) merge driver.
	 */
	.git_merge_file_favor_t file_favor;

	/** see `git_merge_file_flag_t` above */
	uint file_flags;
}

enum GIT_MERGE_OPTIONS_VERSION = 1;

pragma(inline, true)
pure nothrow @safe @nogc
.git_merge_options GIT_MERGE_OPTIONS_INIT()

	do
	{
		.git_merge_options OUTPUT =
		{
			version_: .GIT_MERGE_OPTIONS_VERSION,
			flags: .git_merge_flag_t.GIT_MERGE_FIND_RENAMES,
		};

		return OUTPUT;
	}

/**
 * Initialize git_merge_options structure
 *
 * Initializes a `git_merge_options` with default values. Equivalent to
 * creating an instance with `GIT_MERGE_OPTIONS_INIT`.
 *
 * @param opts The `git_merge_options` struct to initialize.
 * @param version The struct version; pass `GIT_MERGE_OPTIONS_VERSION`.
 * @return Zero on success; -1 on failure.
 */
//GIT_EXTERN
int git_merge_options_init(.git_merge_options* opts, uint version_);

/**
 * The results of `git_merge_analysis` indicate the merge opportunities.
 */
enum git_merge_analysis_t
{
	/** No merge is possible.  (Unused.) */
	GIT_MERGE_ANALYSIS_NONE = 0,

	/**
	 * A "normal" merge; both HEAD and the given merge input have diverged
	 * from their common ancestor.  The divergent commits must be merged.
	 */
	GIT_MERGE_ANALYSIS_NORMAL = (1 << 0),

	/**
	 * All given merge inputs are reachable from HEAD, meaning the
	 * repository is up-to-date and no merge needs to be performed.
	 */
	GIT_MERGE_ANALYSIS_UP_TO_DATE = (1 << 1),

	/**
	 * The given merge input is a fast-forward from HEAD and no merge
	 * needs to be performed.  Instead, the client can check out the
	 * given merge input.
	 */
	GIT_MERGE_ANALYSIS_FASTFORWARD = (1 << 2),

	/**
	 * The HEAD of the current repository is "unborn" and does not point to
	 * a valid commit.  No merge can be performed, but the caller may wish
	 * to simply set HEAD to the target commit(s).
	 */
	GIT_MERGE_ANALYSIS_UNBORN = (1 << 3),
}

/**
 * The user's stated preference for merges.
 */
enum git_merge_preference_t
{
	/**
	 * No configuration was found that suggests a preferred behavior for
	 * merge.
	 */
	GIT_MERGE_PREFERENCE_NONE = 0,

	/**
	 * There is a `merge.ff=false` configuration setting, suggesting that
	 * the user does not want to allow a fast-forward merge.
	 */
	GIT_MERGE_PREFERENCE_NO_FASTFORWARD = (1 << 0),

	/**
	 * There is a `merge.ff=only` configuration setting, suggesting that
	 * the user only wants fast-forward merges.
	 */
	GIT_MERGE_PREFERENCE_FASTFORWARD_ONLY = (1 << 1),
}

/**
 * Analyzes the given branch(es) and determines the opportunities for
 * merging them into the HEAD of the repository.
 *
 * @param analysis_out analysis enumeration that the result is written into
 * @param repo the repository to merge
 * @param their_heads the heads to merge into
 * @param their_heads_len the number of heads to merge
 * @return 0 on success or error code
 */
//GIT_EXTERN
int git_merge_analysis(.git_merge_analysis_t* analysis_out, .git_merge_preference_t* preference_out, libgit2_d.types.git_repository* repo, const (libgit2_d.types.git_annotated_commit)** their_heads, size_t their_heads_len);

/**
 * Analyzes the given branch(es) and determines the opportunities for
 * merging them into a reference.
 *
 * @param analysis_out analysis enumeration that the result is written into
 * @param repo the repository to merge
 * @param our_ref the reference to perform the analysis from
 * @param their_heads the heads to merge into
 * @param their_heads_len the number of heads to merge
 * @return 0 on success or error code
 */
//GIT_EXTERN
int git_merge_analysis_for_ref(.git_merge_analysis_t* analysis_out, .git_merge_preference_t* preference_out, libgit2_d.types.git_repository* repo, libgit2_d.types.git_reference* our_ref, const (libgit2_d.types.git_annotated_commit)** their_heads, size_t their_heads_len);

/**
 * Find a merge base between two commits
 *
 * @param out_ the OID of a merge base between 'one' and 'two'
 * @param repo the repository where the commits exist
 * @param one one of the commits
 * @param two the other commit
 * @return 0 on success, git_error_code.GIT_ENOTFOUND if not found or error code
 */
//GIT_EXTERN
int git_merge_base(libgit2_d.oid.git_oid* out_, libgit2_d.types.git_repository* repo, const (libgit2_d.oid.git_oid)* one, const (libgit2_d.oid.git_oid)* two);

/**
 * Find merge bases between two commits
 *
 * @param out_ array in which to store the resulting ids
 * @param repo the repository where the commits exist
 * @param one one of the commits
 * @param two the other commit
 * @return 0 on success, git_error_code.GIT_ENOTFOUND if not found or error code
 */
//GIT_EXTERN
int git_merge_bases(libgit2_d.oidarray.git_oidarray* out_, libgit2_d.types.git_repository* repo, const (libgit2_d.oid.git_oid)* one, const (libgit2_d.oid.git_oid)* two);

/**
 * Find a merge base given a list of commits
 *
 * @param out_ the OID of a merge base considering all the commits
 * @param repo the repository where the commits exist
 * @param length The number of commits in the provided `input_array`
 * @param input_array oids of the commits
 * @return Zero on success; git_error_code.GIT_ENOTFOUND or -1 on failure.
 */
//GIT_EXTERN
int git_merge_base_many(libgit2_d.oid.git_oid* out_, libgit2_d.types.git_repository* repo, size_t length, const libgit2_d.oid.git_oid[] input_array);

/**
 * Find all merge bases given a list of commits
 *
 * @param out_ array in which to store the resulting ids
 * @param repo the repository where the commits exist
 * @param length The number of commits in the provided `input_array`
 * @param input_array oids of the commits
 * @return Zero on success; git_error_code.GIT_ENOTFOUND or -1 on failure.
 */
//GIT_EXTERN
int git_merge_bases_many(libgit2_d.oidarray.git_oidarray* out_, libgit2_d.types.git_repository* repo, size_t length, const libgit2_d.oid.git_oid[] input_array);

/**
 * Find a merge base in preparation for an octopus merge
 *
 * @param out_ the OID of a merge base considering all the commits
 * @param repo the repository where the commits exist
 * @param length The number of commits in the provided `input_array`
 * @param input_array oids of the commits
 * @return Zero on success; git_error_code.GIT_ENOTFOUND or -1 on failure.
 */
//GIT_EXTERN
int git_merge_base_octopus(libgit2_d.oid.git_oid* out_, libgit2_d.types.git_repository* repo, size_t length, const libgit2_d.oid.git_oid[] input_array);

/**
 * Merge two files as they exist in the in-memory data structures, using
 * the given common ancestor as the baseline, producing a
 * `git_merge_file_result` that reflects the merge result.  The
 * `git_merge_file_result` must be freed with `git_merge_file_result_free`.
 *
 * Note that this function does not reference a repository and any
 * configuration must be passed as `git_merge_file_options`.
 *
 * @param out_ The git_merge_file_result to be filled in
 * @param ancestor The contents of the ancestor file
 * @param ours The contents of the file in "our" side
 * @param theirs The contents of the file in "their" side
 * @param opts The merge file options or `null` for defaults
 * @return 0 on success or error code
 */
//GIT_EXTERN
int git_merge_file(.git_merge_file_result* out_, const (.git_merge_file_input)* ancestor, const (.git_merge_file_input)* ours, const (.git_merge_file_input)* theirs, const (.git_merge_file_options)* opts);

/**
 * Merge two files as they exist in the index, using the given common
 * ancestor as the baseline, producing a `git_merge_file_result` that
 * reflects the merge result.  The `git_merge_file_result` must be freed with
 * `git_merge_file_result_free`.
 *
 * @param out_ The git_merge_file_result to be filled in
 * @param repo The repository
 * @param ancestor The index entry for the ancestor file (stage level 1)
 * @param ours The index entry for our file (stage level 2)
 * @param theirs The index entry for their file (stage level 3)
 * @param opts The merge file options or null
 * @return 0 on success or error code
 */
//GIT_EXTERN
int git_merge_file_from_index(.git_merge_file_result* out_, libgit2_d.types.git_repository* repo, const (libgit2_d.index.git_index_entry)* ancestor, const (libgit2_d.index.git_index_entry)* ours, const (libgit2_d.index.git_index_entry)* theirs, const (.git_merge_file_options)* opts);

/**
 * Frees a `git_merge_file_result`.
 *
 * @param result The result to free or `null`
 */
//GIT_EXTERN
void git_merge_file_result_free(.git_merge_file_result* result);

/**
 * Merge two trees, producing a `git_index` that reflects the result of
 * the merge.  The index may be written as-is to the working directory
 * or checked out.  If the index is to be converted to a tree, the caller
 * should resolve any conflicts that arose as part of the merge.
 *
 * The returned index must be freed explicitly with `git_index_free`.
 *
 * @param out_ pointer to store the index result in
 * @param repo repository that contains the given trees
 * @param ancestor_tree the common ancestor between the trees (or null if none)
 * @param our_tree the tree that reflects the destination tree
 * @param their_tree the tree to merge in to `our_tree`
 * @param opts the merge tree options (or null for defaults)
 * @return 0 on success or error code
 */
//GIT_EXTERN
int git_merge_trees(libgit2_d.types.git_index** out_, libgit2_d.types.git_repository* repo, const (libgit2_d.types.git_tree)* ancestor_tree, const (libgit2_d.types.git_tree)* our_tree, const (libgit2_d.types.git_tree)* their_tree, const (.git_merge_options)* opts);

/**
 * Merge two commits, producing a `git_index` that reflects the result of
 * the merge.  The index may be written as-is to the working directory
 * or checked out.  If the index is to be converted to a tree, the caller
 * should resolve any conflicts that arose as part of the merge.
 *
 * The returned index must be freed explicitly with `git_index_free`.
 *
 * @param out_ pointer to store the index result in
 * @param repo repository that contains the given trees
 * @param our_commit the commit that reflects the destination tree
 * @param their_commit the commit to merge in to `our_commit`
 * @param opts the merge tree options (or null for defaults)
 * @return 0 on success or error code
 */
//GIT_EXTERN
int git_merge_commits(libgit2_d.types.git_index** out_, libgit2_d.types.git_repository* repo, const (libgit2_d.types.git_commit)* our_commit, const (libgit2_d.types.git_commit)* their_commit, const (.git_merge_options)* opts);

/**
 * Merges the given commit(s) into HEAD, writing the results into the working
 * directory.  Any changes are staged for commit and any conflicts are written
 * to the index.  Callers should inspect the repository's index after this
 * completes, resolve any conflicts and prepare a commit.
 *
 * For compatibility with git, the repository is put into a merging
 * state. Once the commit is done (or if the uses wishes to abort),
 * you should clear this state by calling
 * `git_repository_state_cleanup()`.
 *
 * @param repo the repository to merge
 * @param their_heads the heads to merge into
 * @param their_heads_len the number of heads to merge
 * @param merge_opts merge options
 * @param checkout_opts checkout options
 * @return 0 on success or error code
 */
//GIT_EXTERN
int git_merge(libgit2_d.types.git_repository* repo, const (libgit2_d.types.git_annotated_commit)** their_heads, size_t their_heads_len, const (.git_merge_options)* merge_opts, const (libgit2_d.checkout.git_checkout_options)* checkout_opts);

/** @} */
